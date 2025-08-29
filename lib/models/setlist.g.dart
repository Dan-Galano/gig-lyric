// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setlist.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SetlistAdapter extends TypeAdapter<Setlist> {
  @override
  final int typeId = 0;

  @override
  Setlist read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Setlist(
      id: fields[0] as int,
      name: fields[1] as String,
      date: fields[2] as String,
      songs: (fields[3] as List).cast<SongLyrics>(),
    );
  }

  @override
  void write(BinaryWriter writer, Setlist obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.songs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetlistAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
