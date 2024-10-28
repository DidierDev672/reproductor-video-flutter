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

            return GestureDetector(
              onHorizontalDragStart: (details) {
                widget.controller.pause();
              },
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final Offset localPosition =
                    box.globalToLocal(details.globalPosition);
                final double progress = localPosition.dx / box.size.width;
                final Duration newPosition = duration * progress;
                widget.controller.seekTo(newPosition);
              },
              onHorizontalDragEnd: (details) {
                widget.controller.play();
              },
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final Offset localPosition =
                    box.globalToLocal(details.globalPosition);
                final double progress = localPosition.dx / box.size.width;
                final Duration newPosition = duration * progress;
                widget.onSeek(newPosition);
              },
              child: FadeOutDown(
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
                  )),
                ),
              ),
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

  _ProgressBarPainter({
    required this.position,
    required this.duration,
    required this.bufferedPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const height = 2.5;
    const handleRadius = 6.5;

    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    // Fondo
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromPoints(Offset(0, size.height / 2 - height / 2),
                Offset(size.width, size.height / 2 + height / 2)),
            const Radius.circular(4)),
        paint);

    // Búfer
    paint.color = Colors.transparent;
    final double bufferedWidth = size.width *
        (bufferedPosition.inMilliseconds / duration.inMilliseconds);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(Offset(0, size.height / 2 - height / 2),
            Offset(bufferedWidth, size.width / 2 + height / 2)),
        const Radius.circular(2),
      ),
      paint,
    );

    // Progreso
    paint.color = Colors.red;
    final double progressWidth =
        size.width * (position.inMilliseconds / duration.inMilliseconds);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(Offset(0, size.height / 2 - height / 2),
            Offset(progressWidth, size.height / 2 + height / 2)),
        const Radius.circular(4),
      ),
      paint,
    );

    // Manejo
    paint.color = Colors.red;
    canvas.drawCircle(
      Offset(progressWidth, size.height / 2),
      handleRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
