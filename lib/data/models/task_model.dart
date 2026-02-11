import 'package:hive/hive.dart';

part 'task_model.g.dart';

/// Task model for daily task tracking
///
/// Stored in Hive with TypeAdapter for efficient serialization.
/// Priority: 1 = Low, 2 = Medium, 3 = High
@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  int priority;

  @HiveField(4)
  DateTime? dueDate;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  int streakCount;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    this.priority = 2,
    this.dueDate,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.streakCount = 0,
  });

  /// Create a copy with updated fields
  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    int? priority,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? streakCount,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      streakCount: streakCount ?? this.streakCount,
    );
  }

  /// Check if task is due today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  /// Check if task is overdue
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return dueDate!.isBefore(DateTime.now());
  }

  @override
  String toString() =>
      'TaskModel(id: $id, title: $title, isCompleted: $isCompleted)';
}
