import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:giglyric_latest/data/hive_boxes.dart';
import 'package:giglyric_latest/models/lyrics.dart';
import 'package:giglyric_latest/models/setlist.dart';
import 'package:giglyric_latest/screens/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SetlistAdapter());
  Hive.registerAdapter(SongLyricsAdapter());
  lyricsBox = await Hive.openBox<SongLyrics>('lyricsBox');
  setlistBox = await Hive.openBox<Setlist>('setlistBox');
  runApp(const GigLyricApp());
}

class GigLyricApp extends StatelessWidget {
  const GigLyricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Montserrat',
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
