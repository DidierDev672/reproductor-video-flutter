import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_flutter/CustomVideoProgressBar.dart';
import 'package:animate_do/animate_do.dart';

class CustomVideoPlayerScreen extends StatefulWidget {
  final String videoAsset;
  final VideoPlayerController controller;

  const CustomVideoPlayerScreen({
    super.key,
    required this.controller,
    required this.videoAsset,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomVideoPlayerScreenState createState() =>
      _CustomVideoPlayerScreenState();
}

class _CustomVideoPlayerScreenState extends State<CustomVideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  bool _isFullScreen = false;
  bool _isPlaying = false;
  Timer? _hideTimer;
  bool _isDisposed = false;
  bool _isInitialized = false;
  int _currentQualityIndex = 0;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoAsset);
      await _controller.initialize();
      if (!_isDisposed) {
        setState(() {
          _controller.addListener(_videoListener);
          _isInitialized = true;
        });
        _controller.addListener(_videoListener);
      }
    } catch (error) {
      print('Error initializing video controller: $error');
    }
  }

  void _videoListener() {
    if (_controller.value.hasError) {
      print('Video error: ${_controller.value.errorDescription}');
    }

    setState(() {
      _position = _controller.value.position;
    });
  }

  void _changeQuality(int index) async {
    if (index == _currentQualityIndex) return;

    _position = _controller.value.position;
    _isPlaying = _controller.value.isPlaying;

    await _controller.pause();
    await _controller.dispose();

    setState(() {
      _currentQualityIndex = index;
    });

    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        _controller.seekTo(_position);
        if (_isPlaying) {
          _controller.play();
        }
        setState(() {});
      });

    _controller.addListener(_videoListener);
  }

  void _playPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = _controller.value.isPlaying;
    });
  }

  void _showHideControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startHideTimer();
      } else {
        _hideTimer?.cancel();
      }
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _seekRelative(Duration duration) {
    final newPosition = _controller.value.position + duration;
    _controller.seekTo(newPosition);
  }

  void _toggleFullScreen() {
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
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
            overlays: SystemUiOverlay.values);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isDisposed) return Container();
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Center(
              child: _isInitialized && _controller != null
                  ? AspectRatio(
                      aspectRatio: isLandscape
                          ? _controller.value.aspectRatio
                          : _controller.value.aspectRatio * 9 / 16,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          VideoPlayer(_controller),
                          Positioned.fill(
                            child: GestureDetector(
                              onTap: _showHideControls,
                              onDoubleTap: () {
                                _playPause();
                                setState(() {
                                  _showControls = !_showControls;
                                });
                              },
                            ),
                          ),
                          if (_showControls) _buildControls(isLandscape),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(bool isLandscape) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElasticInDown(
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text('Video Player'),
                    centerTitle: true,
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElasticIn(
                        child: IconButton(
                          icon: const Icon(Icons.replay_10),
                          onPressed: () {
                            _seekRelative(const Duration(seconds: -10));
                            _startHideTimer();
                          },
                          color: Colors.white,
                          iconSize: 36,
                        ),
                      ),
                      const SizedBox(width: 20),
                      BounceInDown(
                        child: IconButton(
                          onPressed: () {
                            _playPause();
                            _startHideTimer();
                          },
                          icon:
                              Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                          color: Colors.white,
                          iconSize: 48,
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElasticIn(
                        child: IconButton(
                          onPressed: () {
                            _seekRelative(const Duration(seconds: 10));
                            _startHideTimer();
                          },
                          icon: const Icon(Icons.forward_10),
                          color: Colors.white,
                          iconSize: 36,
                        ),
                      )
                    ],
                  ),
                ),
                const Spacer(),
                ElasticInUp(
                  child: Column(
                    children: [
                      CustomVideoProgressBar(
                        controller: _controller,
                        onSeek: (duration) {
                          _controller.seekTo(duration);
                          _startHideTimer();
                        },
                      ),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        IconButton(
                          onPressed: _toggleFullScreen,
                          icon: Icon(isLandscape
                              ? Icons.fullscreen_exit
                              : Icons.fullscreen),
                          color: Colors.white,
                        )
                      ]),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _hideTimer?.cancel();
    _controller.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _controller.removeListener(_videoListener);
    super.dispose();
  }
}
