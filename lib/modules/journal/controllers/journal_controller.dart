import 'package:get/get.dart';
import 'package:daily_dose/data/models/journal_entry_model.dart';
import 'package:daily_dose/data/repositories/journal_repository.dart';

/// Controller for Journal/Mood Tracker module
///
/// Manages journal entries, mood selection, and trend display.
class JournalController extends GetxController {
  final JournalRepository _journalRepo;

  JournalController({required JournalRepository journalRepo})
    : _journalRepo = journalRepo;

  // ============ REACTIVE STATE ============

  final RxBool isLoading = false.obs;
  final RxList<JournalEntryModel> entries = <JournalEntryModel>[].obs;
  final RxInt selectedMood = 3.obs;
  final RxString content = ''.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxList<double> moodTrend = <double>[].obs;

  // ============ LIFECYCLE ============

  @override
  void onInit() {
    super.onInit();
    loadEntries();
  }

  // ============ DATA LOADING ============

  /// Load all journal entries and mood trend
  void loadEntries() {
    isLoading.value = true;

    entries.value = _journalRepo.getAllEntries();
    moodTrend.value = _journalRepo.getMoodTrend(days: 7);

    isLoading.value = false;
  }

  // ============ ACTIONS ============

  /// Save a new journal entry
  Future<void> saveEntry() async {
    if (selectedMood.value < 1) return;

    await _journalRepo.createEntry(
      mood: selectedMood.value,
      content: content.value.isNotEmpty ? content.value : null,
      tags: selectedTags.toList(),
    );

    // Reset form
    selectedMood.value = 3;
    content.value = '';
    selectedTags.clear();

    loadEntries();
  }

  /// Update an existing entry
  Future<void> updateEntry(JournalEntryModel entry) async {
    await _journalRepo.updateEntry(entry);
    loadEntries();
  }

  /// Delete an entry
  Future<void> deleteEntry(String id) async {
    await _journalRepo.deleteEntry(id);
    loadEntries();
  }

  /// Toggle a tag selection
  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  // ============ COMPUTED GETTERS ============

  /// Today's entry (if exists)
  JournalEntryModel? get todaysEntry => _journalRepo.getTodaysEntry();

  /// Whether user has already logged today
  bool get hasLoggedToday => todaysEntry != null;

  /// Weekly mood average
  double get weeklyMoodAverage => _journalRepo.getMoodAverage(days: 7);

  /// Most used tags
  Map<String, int> get topTags => _journalRepo.getMostUsedTags(limit: 5);

  /// Total entries count
  int get totalEntries => _journalRepo.getTotalEntriesCount();
}
