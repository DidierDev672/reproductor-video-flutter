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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElasticInDown(
                  child: AppBar(
                    foregroundColor: Colors.white,
                    automaticallyImplyLeading: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: const Text(
                      'Video Player',
                      style: TextStyle(color: Colors.white),
                    ),
                    centerTitle: true,
                  ),
                ),
                const SizedBox(height: 80),
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

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
    bool isLandscape = false,
  }) {
    return FadeIn(
      duration: const Duration(milliseconds: 300),
      child: Stack(
        children: [
          // Gradiente superior
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Gradiente inferior
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 150,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Controles principales
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // Barra superior
            ElasticInDown(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Video Player',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        // Implementar menú de configuración.
                      },
                    )
                  ],
                ),
              ),
            ),

            // Controles centrales
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildControlButton(
                    icon: Icons.replay_10,
                    size: 36,
                    onPressed: () => _seekRelative(
                      const Duration(seconds: -10),
                    ),
                  ),
                  const SizedBox(width: 32),
                  _buildPlayPauseButton(),
                  const SizedBox(width: 32),
                  _buildControlButton(
                    icon: Icons.forward_10,
                    size: 36,
                    onPressed: () => _seekRelative(const Duration(seconds: 10)),
                  )
                ],
              ),
            ),

            // Controles inferiores
            ElasticInUp(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CustomVideoProgressBar(
                      controller: _controller,
                      onSeek: (duration) {
                        _controller.seekTo(duration);
                        _startHideTimer();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildVolumeControl(),
                        Row(
                          children: [
                            _buildQualityButton(),
                            const SizedBox(width: 16),
                            _buildFullScreenButton(isLandscape),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )
          ]),
        ],
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(50),
        onTap: () {
          _playPause();
          _startHideTimer();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white24,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: Colors.white,
            size: 48,
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeControl() {
    return Row(children: [
      const Icon(
        Icons.volume_up,
        color: Colors.white,
        size: 24,
      ),
      const SizedBox(width: 8),
      SizedBox(
        width: 100,
        child: Slider(
          value: _controller.value.volume,
          onChanged: (value) {
            setState(() {
              _controller.setVolume(value);
            });
          },
          activeColor: Colors.red,
          inactiveColor: Colors.white30,
        ),
      )
    ]);
  }

  Widget _buildQualityButton() {
    return _buildControlButton(
      icon: Icons.hd,
      size: 24,
      onPressed: () {},
    );
  }

  Widget _buildFullScreenButton(bool isLandscape) {
    return _buildControlButton(
      icon: isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
      size: 36,
      onPressed: _toggleFullScreen,
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
