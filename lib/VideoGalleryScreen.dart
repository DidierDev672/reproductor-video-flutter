import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player_flutter/VideoCard.dart';
import 'package:video_player_flutter/services/isar_service.dart';

class VideoGalleryScreen extends StatefulWidget {
  const VideoGalleryScreen({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _VideoGalleryScreenState createState() => _VideoGalleryScreenState();
}

class _VideoGalleryScreenState extends State<VideoGalleryScreen> {
  final IsarService _isarService = IsarService();
  //! Lista e URL de videosUrls
  final List<String> videoUrls = [
    'assets/4_Tipso_Steam_and_Froth_The_Perfect_milk_for_Latte_Art.mp4',
    'assets/5_Tips_to_Steam_Milk_for_Latte_art_3_Minutes_Tutorial.mp4',
    'assets/Coffee_Tips_How_To_Prepare_Turkish_Coffee_Using_A_Cezve.mp4',
    'assets/How_To_Make_Hot_Coffee_(Perfect_Frothy_Coffee_At_Home).mp4',
    'assets/Cinema_Line_FX3_Muestra_video_Sony.mp4',
    'assets/Forza_Horizon_5_Official_Announce.mp4',
    'assets/2_AM_COFFEE_A_short_film_Sony_FX3.mp4',
    'assets/DAYDREAMERSSonyFX3film.mp4',
    'assets/MatchaLatteArtAesthetic.mp4',
    'assets/MovementsyouNeedforLatteArt.mp4',
    'assets/ThishastoSTOPWooting80ETeaser.mp4',
    'assets/PS5ProEnhancedMarvelsSpiderMan2.mp4',
    'assets/GodofWarRagnarökPS5PS4.mp4'
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galería de Videos'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: videoUrls.isEmpty ? _isarService.getAllVideos() : null,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  delay: Duration(milliseconds: 100 * index),
                  child: VideoCard(
                    video: snapshot.data![index],
                    isarService: _isarService,
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
