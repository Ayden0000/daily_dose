import 'package:hive/hive.dart';
import 'package:daily_dose/data/models/goal_milestone_model.dart';

part 'goal_model.g.dart';

/// Goal model for long-term goal tracking with milestones
///
/// Goals are strategic objectives (30/60/90 days) broken into
/// actionable milestones. Progress is measured by milestone completion.
@HiveType(typeId: 7)
class GoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String category;

  @HiveField(4)
  DateTime targetDate;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  DateTime? completedAt;

  @HiveField(8)
  List<GoalMilestoneModel> milestones;

  GoalModel({
    required this.id,
    required this.title,
    this.description,
    this.category = 'Personal',
    required this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
    this.completedAt,
    this.milestones = const [],
  });

  /// Calculate progress as a fraction (0.0 - 1.0)
  double get progress {
    if (milestones.isEmpty) return isCompleted ? 1.0 : 0.0;
    final completed = milestones.where((m) => m.isCompleted).length;
    return completed / milestones.length;
  }

  /// Number of completed milestones
  int get completedMilestoneCount =>
      milestones.where((m) => m.isCompleted).length;

  /// Check if the goal is overdue
  bool get isOverdue {
    if (isCompleted) return false;
    return targetDate.isBefore(DateTime.now());
  }

  /// Days remaining until target date
  int get daysRemaining {
    final now = DateTime.now();
    return targetDate.difference(now).inDays;
  }

  /// Create a copy with updated fields
  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? targetDate,
    DateTime? createdAt,
    bool? isCompleted,
    DateTime? completedAt,
    List<GoalMilestoneModel>? milestones,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      milestones: milestones ?? this.milestones,
    );
  }

  @override
  String toString() =>
      'GoalModel(id: $id, title: $title, progress: ${(progress * 100).toStringAsFixed(0)}%)';
}
