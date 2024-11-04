import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:animate_do/animate_do.dart';

class CustomVideoProgressBar extends StatefulWidget {
  final VideoPlayerController controller;
  final Function(Duration) onSeek;

  const CustomVideoProgressBar({
    super.key,
    required this.controller,
    required this.onSeek,
  });

  @override
  State<CustomVideoProgressBar> createState() => _CustomVideoProgressBarState();
}

class _CustomVideoProgressBarState extends State<CustomVideoProgressBar> {
  bool _isDragging = false;
  Duration? _previewPosition;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${duration.inHours > 0 ? '${twoDigits(duration.inHours)} : ' : ''}$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.controller.position.asStream(),
      builder: (context, snapshot) {
        return ValueListenableBuilder(
          valueListenable: widget.controller,
          builder: (context, VideoPlayerValue value, child) {
            final duration = value.duration;
            final position = value.position;

            if (duration.inMilliseconds == 0) {
              return const SizedBox();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isDragging)
                  FadeIn(
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _formatDuration(_previewPosition ?? position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                GestureDetector(
                  onHorizontalDragStart: (details) {
                    setState(() {
                      _isDragging = true;
                    });
                    widget.controller.pause();
                  },
                  onHorizontalDragUpdate: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final Offset localPosition =
                        box.globalToLocal(details.globalPosition);
                    final double progress =
                        localPosition.dx.clamp(0, box.size.width) /
                            box.size.width;
                    setState(() {
                      _previewPosition = duration * progress;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_previewPosition != null) {
                      widget.onSeek(_previewPosition!);
                    }
                    setState(() {
                      _isDragging = false;
                      _previewPosition = null;
                    });
                    widget.controller.play();
                  },
                  onTapDown: (details) {
                    final box = context.findRenderObject() as RenderBox;
                    final Offset localPosition =
                        box.globalToLocal(details.globalPosition);
                    final double progress =
                        localPosition.dx.clamp(0, box.size.width) /
                            box.size.width;
                    widget.onSeek(duration * progress);
                  },
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    color: Colors.transparent,
                    child: CustomPaint(
                      painter: _ProgressBarPainter(
                        position: position,
                        duration: duration,
                        bufferedPosition: value.buffered.isNotEmpty
                            ? value.buffered.last.end
                            : Duration.zero,
                        isDragging: _isDragging,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }
}

class _ProgressBarPainter extends CustomPainter {
  final Duration position;
  final Duration duration;
  final Duration bufferedPosition;
  final bool isDragging;

  _ProgressBarPainter({
    required this.position,
    required this.duration,
    required this.bufferedPosition,
    required this.isDragging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const height = 2.5;
    final handleRadius = isDragging ? 8.5 : 6.5;

    final paint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.fill;

    // Fondo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, size.height / 2 - height / 2),
          Offset(size.width, size.height / 2 + height / 2),
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Búfer
    paint.color = Colors.white10;
    final double bufferedWidth = size.width *
        (bufferedPosition.inMilliseconds / duration.inMilliseconds);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, size.height / 2 - height / 2),
          Offset(bufferedWidth, size.width / 2 + height / 2),
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Progreso
    paint.color = Colors.red;
    final double progressWidth =
        size.width * (position.inMilliseconds / duration.inMilliseconds);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(0, size.height / 2 - height / 2),
          Offset(progressWidth, size.height / 2 + height / 2),
        ),
        const Radius.circular(4),
      ),
      paint,
    );

    // Handle con sombra
    if (isDragging) {
      paint.color = Colors.black26;
      canvas.drawCircle(
        Offset(progressWidth, size.height / 2),
        handleRadius + 4,
        paint,
      );
    }

    // Manejo
    paint.color = Colors.red;
    canvas.drawCircle(
      Offset(progressWidth, size.height / 2),
      handleRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressBarPainter oldDelegate) =>
      position != oldDelegate.position ||
      duration != oldDelegate.duration ||
      bufferedPosition != oldDelegate.bufferedPosition ||
      isDragging != oldDelegate.isDragging;
}
