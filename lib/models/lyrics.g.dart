// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lyrics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SongLyricsAdapter extends TypeAdapter<SongLyrics> {
  @override
  final int typeId = 1;

  @override
  SongLyrics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SongLyrics(
      id: fields[0] as int,
      title: fields[2] as String,
      artist: fields[3] as String,
      lyrics: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SongLyrics obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.artist)
      ..writeByte(4)
      ..write(obj.lyrics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SongLyricsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
