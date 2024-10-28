import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_flutter/CustomVideoProgressBar.dart';
import 'package:video_player_flutter/widgets/controls_overlay.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoPlayerController controller;
  const VideoPlayerScreen({super.key, required this.controller});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isFullScreen = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _controller.addListener(_videoListener);
  }

  void _videoListener() {
    if (!_disposed) setState(() {});
  }

  @override
  void dispose() {
    _disposed = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  void _toggleFullScreen() {
    if (mounted) {
      setState(() {
        _isFullScreen = !_isFullScreen;
        if (_isFullScreen) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        } else {
          SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: SystemUiOverlay.values,
          );
        }
      });
    }
  }

  void _seekTo(Duration position) {
    if (!_disposed) {
      _controller.seekTo(position);
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: isLandscape
                          ? _controller.value.aspectRatio
                          : _controller.value.aspectRatio * 9 / 16,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          VideoPlayer(_controller),
                          ControlsOverlay(controller: _controller),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: CustomVideoProgressBar(
                              controller: _controller,
                              onSeek: _seekTo,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _toggleFullScreen,
            backgroundColor: Colors.white,
            child:
                Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
        );
      },
    );
  }
}
