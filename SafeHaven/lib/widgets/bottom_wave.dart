import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Decorative navy wave with a red stripe, used at the bottom of
/// Onboarding and Login (as in the SafeHaven design).
class BottomWave extends StatelessWidget {
  final double height;
  const BottomWave({super.key, this.height = 56});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _WavePainter()),
    );
  }
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Red stripe (back)
    final red = Path()
      ..moveTo(0, h * 0.28)
      ..cubicTo(w * 0.28, h * 0.02, w * 0.55, h * 0.62, w, h * 0.12)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(red, Paint()..color = AppTheme.accent);

    // Navy wave (front)
    final navy = Path()
      ..moveTo(0, h * 0.52)
      ..cubicTo(w * 0.30, h * 0.26, w * 0.58, h * 0.86, w, h * 0.38)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(navy, Paint()..color = AppTheme.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
