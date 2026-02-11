// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_pattern_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BreathingPatternModelAdapter extends TypeAdapter<BreathingPatternModel> {
  @override
  final int typeId = 2;

  @override
  BreathingPatternModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BreathingPatternModel(
      id: fields[0] as String,
      name: fields[1] as String,
      inhale: fields[2] as int,
      hold1: fields[3] as int,
      exhale: fields[4] as int,
      hold2: fields[5] as int,
      isCustom: fields[6] as bool,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BreathingPatternModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.inhale)
      ..writeByte(3)
      ..write(obj.hold1)
      ..writeByte(4)
      ..write(obj.exhale)
      ..writeByte(5)
      ..write(obj.hold2)
      ..writeByte(6)
      ..write(obj.isCustom)
      ..writeByte(7)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BreathingPatternModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
