import 'package:flutter/material.dart';

class EmptySetlistScreen extends StatelessWidget {
  const EmptySetlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/empty_setlist.png',
      width: 420,
    );
  }
}
