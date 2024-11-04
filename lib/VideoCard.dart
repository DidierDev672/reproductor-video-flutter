import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_flutter/CustomVideoPlayerScreen.dart';
import 'package:animate_do/animate_do.dart';
import 'package:video_player_flutter/domain/VideoModel.dart';
import 'package:video_player_flutter/services/isar_service.dart';

class VideoCard extends StatefulWidget {
  final VideoModel video;
  final IsarService isarService;

  const VideoCard({
    super.key,
    required this.video,
    required this.isarService,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.video.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          // Actualizar la duración en la base de datos.
          widget.video.duration = _controller.value.duration.inSeconds;
          widget.isarService.saveVideo(widget.video);
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context);
    return FadeInDown(
      duration: const Duration(milliseconds: 500),
      delay: const Duration(milliseconds: 100),
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: FadeInDownBig(
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFF8F8F8)],
                )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () async {
                    await widget.isarService.toggleFavorite(widget.video.id);
                    setState(() {});
                  },
                  icon: Icon(
                    widget.video.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.video.isFavorite ? Colors.red : Colors.grey,
                  ),
                ),
                MouseRegion(
                  onEnter: (_) => _onHover(true),
                  onExit: (_) => _onHover(false),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _isInitialized
                          ? VideoPlayer(_controller)
                          : const Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomVideoPlayerScreen(
                            controller: _controller,
                            videoAsset: widget.video.videoUrl,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeIn(
                          child: Text(
                            'Video ${widget.video.videoUrl.split('/').last}',
                            style: textStyle.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 8),
                        FadeIn(
                          child: Text(
                            'Duración: ${_formatDuration(_controller.value.duration)}',
                            style: textStyle.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        ElasticInLeft(
                          duration: const Duration(milliseconds: 500),
                          delay: const Duration(milliseconds: 100),
                          curve: Curves.bounceInOut,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomVideoPlayerScreen(
                                    controller: _controller,
                                    videoAsset: widget.video.videoUrl,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Reproducir',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
      if (_isHovering) {
        _controller.play();
      } else {
        _controller.pause();
        _controller.seekTo(Duration.zero);
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}
