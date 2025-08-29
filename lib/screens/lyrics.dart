import 'package:flutter/material.dart';
import 'package:giglyric_latest/models/lyrics.dart';
import 'package:gap/gap.dart';

class LyricsScreen extends StatelessWidget {
  LyricsScreen({super.key, required this.songLyrics});

  final SongLyrics songLyrics;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "GigLyric",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(24),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  songLyrics.title,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const Gap(24),
              Text(
                songLyrics.lyrics,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
