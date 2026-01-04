// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cheatsheet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheatSheetAdapter extends TypeAdapter<CheatSheet> {
  @override
  final int typeId = 10;

  @override
  CheatSheet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheatSheet(
      id: fields[0] as String,
      title: fields[1] as String,
      category: fields[2] as String,
      icon: fields[3] as String,
      url: fields[4] as String,
      difficulty: fields[5] as String,
      tags: (fields[6] as List).cast<String>(),
      description: fields[7] as String,
      isFavorite: fields[8] as bool,
      viewCount: fields[9] as int,
      lastViewed: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CheatSheet obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.icon)
      ..writeByte(4)
      ..write(obj.url)
      ..writeByte(5)
      ..write(obj.difficulty)
      ..writeByte(6)
      ..write(obj.tags)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.viewCount)
      ..writeByte(10)
      ..write(obj.lastViewed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheatSheetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
