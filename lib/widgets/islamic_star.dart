import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:the_open_quran/constants/constants.dart';

/// 8-pointed Islamic star (rub el hizb style) with optional center text (e.g. surah number).
class IslamicStar extends StatelessWidget {
  const IslamicStar({
    super.key,
    this.size = 36,
    this.color,
    this.child,
  });

  final double size;
  final Color? color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final c = color ?? DesignSystem.iconGreen;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IslamicStarPainter(color: c),
        child: child != null
            ? Center(
                child: DefaultTextStyle(
                  style: TextStyle(
                    fontSize: size * 0.36,
                    fontWeight: FontWeight.w700,
                    color: c,
                  ),
                  child: child!,
                ),
              )
            : null,
      ),
    );
  }
}

class _IslamicStarPainter extends CustomPainter {
  _IslamicStarPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    final path = Path();
    const int points = 8;
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.4;
      final angle = (i * (math.pi / points)) - (math.pi / 2);
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
