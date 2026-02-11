import 'package:hive/hive.dart';

part 'journal_entry_model.g.dart';

/// Journal entry model for daily mood and reflection tracking
///
/// Combines mood scoring (1-5 scale) with optional text entries
/// and predefined tags for quick categorization.
@HiveType(typeId: 6)
class JournalEntryModel extends HiveObject {
  @HiveField(0)
  final String id;

  /// Mood score: 1=Awful, 2=Bad, 3=Okay, 4=Good, 5=Great
  @HiveField(1)
  int mood;

  /// Optional free-text journal content
  @HiveField(2)
  String? content;

  /// Predefined tags: Productive, Stressed, Energetic, etc.
  @HiveField(3)
  List<String> tags;

  @HiveField(4)
  final DateTime createdAt;

  JournalEntryModel({
    required this.id,
    required this.mood,
    this.content,
    this.tags = const [],
    required this.createdAt,
  });

  /// Check if entry is from today
  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  /// Check if entry is from a specific date
  bool isForDate(DateTime date) {
    return createdAt.year == date.year &&
        createdAt.month == date.month &&
        createdAt.day == date.day;
  }

  /// Create a copy with updated fields
  JournalEntryModel copyWith({
    String? id,
    int? mood,
    String? content,
    List<String>? tags,
    DateTime? createdAt,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() => 'JournalEntryModel(id: $id, mood: $mood, tags: $tags)';
}
