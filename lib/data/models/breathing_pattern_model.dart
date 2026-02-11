import 'package:hive/hive.dart';

part 'breathing_pattern_model.g.dart';

/// Breathing pattern model for meditation
///
/// Pattern consists of 4 phases measured in beats at 50 BPM (1.2s per beat):
/// - inhale: beats to breathe in
/// - hold1: beats to hold after inhale
/// - exhale: beats to breathe out
/// - hold2: beats to hold after exhale
@HiveType(typeId: 2)
class BreathingPatternModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int inhale;

  @HiveField(3)
  int hold1;

  @HiveField(4)
  int exhale;

  @HiveField(5)
  int hold2;

  @HiveField(6)
  bool isCustom;

  @HiveField(7)
  final DateTime createdAt;

  BreathingPatternModel({
    required this.id,
    required this.name,
    required this.inhale,
    required this.hold1,
    required this.exhale,
    required this.hold2,
    this.isCustom = false,
    required this.createdAt,
  });

  /// Total duration of one breathing cycle in seconds
  int get cycleDuration => inhale + hold1 + exhale + hold2;

  /// Pattern as formatted string (e.g., "4-7-8-0")
  String get patternString => '$inhale-$hold1-$exhale-$hold2';

  /// Create a copy with updated fields
  BreathingPatternModel copyWith({
    String? id,
    String? name,
    int? inhale,
    int? hold1,
    int? exhale,
    int? hold2,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return BreathingPatternModel(
      id: id ?? this.id,
      name: name ?? this.name,
      inhale: inhale ?? this.inhale,
      hold1: hold1 ?? this.hold1,
      exhale: exhale ?? this.exhale,
      hold2: hold2 ?? this.hold2,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() =>
      'BreathingPatternModel(name: $name, pattern: $patternString)';
}
