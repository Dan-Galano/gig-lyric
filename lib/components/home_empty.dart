import 'package:flutter/material.dart';

class EmptyHomeScreen extends StatelessWidget {
  const EmptyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/empty_songs.png',
      height: 420,
    );
  }
}
