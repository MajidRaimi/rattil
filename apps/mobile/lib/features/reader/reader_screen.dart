import 'package:flutter/material.dart';

class ReaderScreen extends StatelessWidget {
  final int surahNumber;

  const ReaderScreen({super.key, required this.surahNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Reader - Surah $surahNumber')),
    );
  }
}
