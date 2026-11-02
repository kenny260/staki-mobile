import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:staki_mobile/core/theme/app_colors.dart';

class ScoreGauge extends StatelessWidget {
  const ScoreGauge({
    required this.score,
    required this.color,
    required this.bandLabel,
    super.key,
  });

  final int score; // 300 to 1000
  final Color color;
  final String bandLabel;

  @override
  Widget build(BuildContext context) {
    final progress = ((score - 300) / 700).clamp(0.0, 1.0);
    return SizedBox(
      width: 220,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 190),
            painter: _GaugePainter(
              progress: progress,
              color: color,
              trackColor: AppColors.border,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  bandLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  // Arc spans about 260 degrees, opening at the bottom (eyeballed from Figma).
  static const double _start = 140 * math.pi / 180;
  static const double _sweep = 260 * math.pi / 180;
  static const double _stroke = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - _stroke,
    );
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = trackColor;
    final value = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas
      ..drawArc(rect, _start, _sweep, false, track)
      ..drawArc(rect, _start, _sweep * progress, false, value);
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}
