import 'package:hive_flutter/hive_flutter.dart';

part 'lyrics.g.dart';

@HiveType(typeId: 1)
class SongLyrics {
  @HiveField(0)
  int id;

  @HiveField(2)
  String title;

  @HiveField(3)
  String artist;

  @HiveField(4)
  String lyrics;

  SongLyrics({
    required this.id,
    required this.title,
    required this.artist,
    required this.lyrics,
  });
}