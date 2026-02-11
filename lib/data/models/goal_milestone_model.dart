import 'package:hive/hive.dart';

part 'goal_milestone_model.g.dart';

/// Milestone within a Goal
///
/// Represents a measurable step toward completing a goal.
/// Milestones are embedded within GoalModel but have their own
/// HiveType for proper serialization of the nested list.
@HiveType(typeId: 8)
class GoalMilestoneModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime? completedAt;

  @HiveField(4)
  int sortOrder;

  GoalMilestoneModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
    this.sortOrder = 0,
  });

  /// Create a copy with updated fields
  GoalMilestoneModel copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? completedAt,
    int? sortOrder,
  }) {
    return GoalMilestoneModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  String toString() =>
      'GoalMilestoneModel(id: $id, title: $title, done: $isCompleted)';
}
