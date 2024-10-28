import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_flutter/screen_utils.dart';
import 'package:video_player_flutter/widgets/video_player_screen.dart';

class VideoThumbnail extends StatefulWidget {
  final String videoUrl;

  const VideoThumbnail({super.key, required this.videoUrl});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    throw UnimplementedError();
  }
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;
  bool _hasError = false;
  String _errorMessage = '';
  final bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
  }

  void _initializeVideoPlayer() {
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        if (mounted) setState(() {});
      }).catchError((error) {
        print("Error initializing video: ${widget.videoUrl}");
        if (error is PlatformException) {
          print('Error code: ${error.code}');
          print('Error message: ${error.message}');
          print('Error details: ${error.details}');
        }

        setState(() {
          _hasError = true;
          _errorMessage = error.toString();
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    ScreenUtils.setFullScreen(_isFullScreen);
    ScreenUtils.setOrientation(_isFullScreen ? 'landscape' : 'portrait');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!_hasError && _controller.value.isInitialized) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(controller: _controller),
            ),
          );
        }
      },
      child: _hasError
          ? const Center(child: Icon(Icons.error))
          : _controller.value.isInitialized
              ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
              : const Center(child: CircularProgressIndicator()),
    );
  }
}
