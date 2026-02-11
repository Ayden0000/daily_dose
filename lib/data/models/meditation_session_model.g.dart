// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meditation_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeditationSessionModelAdapter
    extends TypeAdapter<MeditationSessionModel> {
  @override
  final int typeId = 3;

  @override
  MeditationSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeditationSessionModel(
      id: fields[0] as String,
      patternId: fields[1] as String,
      patternName: fields[2] as String,
      durationSeconds: fields[3] as int,
      completedCycles: fields[4] as int,
      completedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MeditationSessionModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.patternId)
      ..writeByte(2)
      ..write(obj.patternName)
      ..writeByte(3)
      ..write(obj.durationSeconds)
      ..writeByte(4)
      ..write(obj.completedCycles)
      ..writeByte(5)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeditationSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
