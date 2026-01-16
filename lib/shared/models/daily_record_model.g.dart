// lib/shared/models/daily_record_model.g.dart

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyRecordAdapter extends TypeAdapter<DailyRecord> {
  @override
  final int typeId = 6;

  @override
  DailyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRecord(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      selectedTaskIds: (fields[2] as List?)?.cast<int>(),
      freeIntentions: (fields[3] as List?)?.cast<String>(),
      freeIntentionCompleted: (fields[4] as List?)?.cast<bool>(),
      morningCompletedAt: fields[5] as DateTime?,
      eveningReflection: fields[6] as String?,
      satisfactionRating: fields[7] as int?,
      eveningCompletedAt: fields[8] as DateTime?,
      createdAt: fields[9] as DateTime?,
      updatedAt: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecord obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.selectedTaskIds)
      ..writeByte(3)
      ..write(obj.freeIntentions)
      ..writeByte(4)
      ..write(obj.freeIntentionCompleted)
      ..writeByte(5)
      ..write(obj.morningCompletedAt)
      ..writeByte(6)
      ..write(obj.eveningReflection)
      ..writeByte(7)
      ..write(obj.satisfactionRating)
      ..writeByte(8)
      ..write(obj.eveningCompletedAt)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
