import 'package:flutter/material.dart';
import 'package:video_player_flutter/VideoGalleryScreen.dart';
import 'package:video_player_flutter/theme/AppTheme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoGalleryScreen(),
    );
  }
}
