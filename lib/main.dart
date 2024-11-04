import 'package:flutter/material.dart';
import 'package:video_player_flutter/VideoGalleryScreen.dart';
import 'package:video_player_flutter/services/isar_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService().openDB();
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
