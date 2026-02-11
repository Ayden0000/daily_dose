import 'package:uuid/uuid.dart';
import 'package:daily_dose/data/models/journal_entry_model.dart';
import 'package:daily_dose/data/services/storage_service.dart';

/// Repository for journal/mood-related business logic
///
/// Handles CRUD operations, mood trend analysis, and tag statistics.
/// Does NOT contain UI logic — only data operations.
class JournalRepository {
  final StorageService _storageService;
  static const _uuid = Uuid();

  JournalRepository({required StorageService storageService})
    : _storageService = storageService;

  // ============ CRUD ============

  /// Get all entries sorted by date (newest first)
  List<JournalEntryModel> getAllEntries() {
    final entries = _storageService.getAllJournalEntries();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  /// Get entries for a specific date
  List<JournalEntryModel> getEntriesForDate(DateTime date) {
    return getAllEntries().where((e) => e.isForDate(date)).toList();
  }

  /// Get entries for a date range
  List<JournalEntryModel> getEntriesForDateRange(DateTime start, DateTime end) {
    return getAllEntries().where((e) {
      return !e.createdAt.isBefore(start) && !e.createdAt.isAfter(end);
    }).toList();
  }

  /// Get today's entry (most recent if multiple)
  JournalEntryModel? getTodaysEntry() {
    final entries = getEntriesForDate(DateTime.now());
    return entries.isNotEmpty ? entries.first : null;
  }

  /// Get entry by ID
  JournalEntryModel? getEntry(String id) {
    return _storageService.getJournalEntry(id);
  }

  /// Create a new journal entry
  Future<JournalEntryModel> createEntry({
    required int mood,
    String? content,
    List<String> tags = const [],
  }) async {
    final entry = JournalEntryModel(
      id: _uuid.v4(),
      mood: mood,
      content: content,
      tags: tags,
      createdAt: DateTime.now(),
    );
    await _storageService.saveJournalEntry(entry);
    return entry;
  }

  /// Update an existing entry
  Future<void> updateEntry(JournalEntryModel entry) async {
    await _storageService.saveJournalEntry(entry);
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    await _storageService.deleteJournalEntry(id);
  }

  // ============ MOOD ANALYSIS ============

  /// Get average mood for the last N days
  double getMoodAverage({int days = 7}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day - days);

    final entries = getEntriesForDateRange(start, now);
    if (entries.isEmpty) return 0.0;

    final total = entries.fold(0, (sum, e) => sum + e.mood);
    return total / entries.length;
  }

  /// Get mood trend as list of daily averages for the last N days
  ///
  /// Returns a list of doubles (one per day, 0 if no entry).
  /// Ordered from oldest to newest.
  List<double> getMoodTrend({int days = 7}) {
    final trend = <double>[];
    final now = DateTime.now();

    for (var i = days - 1; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayEntries = getEntriesForDate(date);

      if (dayEntries.isEmpty) {
        trend.add(0);
      } else {
        final avg =
            dayEntries.fold(0, (sum, e) => sum + e.mood) / dayEntries.length;
        trend.add(avg);
      }
    }

    return trend;
  }

  /// Get most used tags across all entries
  Map<String, int> getMostUsedTags({int limit = 5}) {
    final tagCounts = <String, int>{};

    for (final entry in getAllEntries()) {
      for (final tag in entry.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    // Sort by count descending
    final sorted = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(limit));
  }

  /// Get total entry count
  int getTotalEntriesCount() {
    return _storageService.getAllJournalEntries().length;
  }
}
