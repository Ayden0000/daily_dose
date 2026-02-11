import 'package:hive/hive.dart';

part 'meditation_session_model.g.dart';

/// Meditation session history model
///
/// Records completed meditation sessions for tracking progress.
@HiveType(typeId: 3)
class MeditationSessionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String patternId;

  @HiveField(2)
  String patternName;

  @HiveField(3)
  int durationSeconds;

  @HiveField(4)
  int completedCycles;

  @HiveField(5)
  final DateTime completedAt;

  MeditationSessionModel({
    required this.id,
    required this.patternId,
    required this.patternName,
    required this.durationSeconds,
    required this.completedCycles,
    required this.completedAt,
  });

  /// Duration formatted as mm:ss
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if session is from today
  bool get isToday {
    final now = DateTime.now();
    return completedAt.year == now.year &&
        completedAt.month == now.month &&
        completedAt.day == now.day;
  }

  @override
  String toString() =>
      'MeditationSessionModel(pattern: $patternName, duration: $formattedDuration)';
}
