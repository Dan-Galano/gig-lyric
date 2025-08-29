import 'package:giglyric_latest/models/lyrics.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'setlist.g.dart';

@HiveType(typeId: 0)
class Setlist {
  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String date;

  @HiveField(3)
  List<SongLyrics> songs;

  Setlist({
    required this.id,
    required this.name,
    required this.date,
    this.songs = const [],
  });
}