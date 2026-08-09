import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile/mera/mera_theme.dart';

class ActivityScoreGauge extends StatelessWidget {
  final double score;
  final ActivityGaugePalette palette;

  const ActivityScoreGauge({
    super.key,
    required this.score,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final s = score.clamp(0, 100);
    return SizedBox(
      width: 118,
      height: 118,
      child: CustomPaint(
        painter: _GaugePainter(
          progress: s / 100,
          track: MeraColors.borderSecondary,
          fill: palette.color,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: palette.color,
                  height: 1,
                ),
              ),
              const Text(
                '/ 100',
                style: TextStyle(
                  fontSize: 12,
                  color: MeraColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityGaugePalette {
  final Color color;
  const ActivityGaugePalette(this.color);

  static ActivityGaugePalette forScore(double score) {
    if (score < 20) return const ActivityGaugePalette(MeraColors.danger);
    if (score < 40) {
      return const ActivityGaugePalette(Color(0xFFFF7A45));
    }
    if (score < 60) return const ActivityGaugePalette(MeraColors.warning);
    if (score < 80) return const ActivityGaugePalette(Color(0xFF9AD94A));
    return const ActivityGaugePalette(MeraColors.green);
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final Color track;
  final Color fill;

  _GaugePainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 8;
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, trackPaint);
    final sweep = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      sweep,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.fill != fill;
}
