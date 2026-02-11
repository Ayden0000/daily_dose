// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_milestone_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalMilestoneModelAdapter extends TypeAdapter<GoalMilestoneModel> {
  @override
  final int typeId = 8;

  @override
  GoalMilestoneModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalMilestoneModel(
      id: fields[0] as String,
      title: fields[1] as String,
      isCompleted: fields[2] as bool,
      completedAt: fields[3] as DateTime?,
      sortOrder: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GoalMilestoneModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.completedAt)
      ..writeByte(4)
      ..write(obj.sortOrder);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalMilestoneModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
