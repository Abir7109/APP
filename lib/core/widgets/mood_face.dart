import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// A soft, dimensional mood face that morphs smoothly between moods.
///
/// The face is painted rather than icon-based so the eyes, brows, blush, and
/// mouth can interpolate from low to amazing instead of snapping between five
/// stock glyphs.
class MoodFace extends StatefulWidget {
  const MoodFace({
    super.key,
    required this.mood,
    required this.color,
    this.size = 56,
    this.animate = true,
  });

  final int mood;
  final Color color;
  final double size;
  final bool animate;

  @override
  State<MoodFace> createState() => _MoodFaceState();
}

class _MoodFaceState extends State<MoodFace>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 460),
  );
  late Animation<double> _mood = AlwaysStoppedAnimation(widget.mood.toDouble());

  @override
  void didUpdateWidget(covariant MoodFace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mood == oldWidget.mood) return;
    _mood = Tween<double>(
      begin: _mood.value,
      end: widget.mood.toDouble(),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final static = !widget.animate || reduceMotion;
    return SizedBox.square(
      dimension: widget.size,
      child: static
          ? CustomPaint(
              painter: _MoodFacePainter(
                mood: widget.mood.toDouble(),
                color: widget.color,
              ),
            )
          : AnimatedBuilder(
              animation: _controller,
              builder: (context, _) => CustomPaint(
                painter: _MoodFacePainter(
                  mood: _mood.value,
                  color: widget.color,
                ),
              ),
            ),
    );
  }
}

class _MoodFacePainter extends CustomPainter {
  const _MoodFacePainter({required this.mood, required this.color});

  final double mood;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    if (s <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = s / 2;
    final t = ((mood - 1) / 4).clamp(0.0, 1.0);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final light = Color.lerp(color, Colors.white, 0.46)!;
    final dark = Color.lerp(color, const Color(0xFF4A1235), 0.3)!;

    canvas.drawCircle(
      center.translate(0, s * 0.035),
      radius * 0.9,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.16)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, s * 0.07),
    );

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.1,
          colors: [light, color, dark],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    canvas.drawArc(
      rect.deflate(s * 0.018),
      math.pi * 1.05,
      math.pi * 0.62,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: 0.38),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-s * 0.17, -s * 0.27),
        width: s * 0.28,
        height: s * 0.15,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.17),
    );

    final blush = Color.lerp(color, const Color(0xFFFF7B83), 0.4)!
        .withValues(alpha: 0.15 + 0.2 * t);
    final blushPaint = Paint()..color = blush;
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(-s * 0.245, s * 0.11),
        width: s * 0.19,
        height: s * 0.1,
      ),
      blushPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(s * 0.245, s * 0.11),
        width: s * 0.19,
        height: s * 0.1,
      ),
      blushPaint,
    );

    const ink = Color(0xFF3E0554);
    const eyeWhite = Color(0xFFFFF7FA);
    final eyeDx = s * 0.19;
    final eyeY = center.dy - s * 0.05;
    final eyeW = s * (0.115 - 0.015 * t);
    final eyeH = s * (0.1 + 0.1 * t);
    final browTilt = s * (0.03 - 0.03 * t);
    final browY = eyeY - s * (0.17 - 0.02 * t);

    for (final sign in const [-1.0, 1.0]) {
      final eyeCenter = Offset(center.dx + sign * eyeDx, eyeY);
      canvas.drawOval(
        Rect.fromCenter(center: eyeCenter, width: eyeW, height: eyeH),
        Paint()..color = eyeWhite,
      );

      final pupilRadius = s * (0.03 + 0.012 * t);
      final pupil = eyeCenter.translate(0, s * 0.008);
      canvas.drawCircle(pupil, pupilRadius, Paint()..color = ink);
      canvas.drawCircle(
        pupil.translate(-pupilRadius * 0.35, -pupilRadius * 0.4),
        pupilRadius * 0.34,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );

      canvas.drawLine(
        Offset(eyeCenter.dx - sign * eyeW * 0.72, browY - browTilt),
        Offset(eyeCenter.dx + sign * eyeW * 0.72, browY + browTilt),
        Paint()
          ..color = ink.withValues(alpha: 0.5)
          ..strokeWidth = s * 0.032
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawCircle(
      center.translate(0, s * 0.09),
      s * 0.012,
      Paint()..color = ink.withValues(alpha: 0.16),
    );

    final mouthY = center.dy + s * 0.19;
    final mouthW = s * (0.23 + 0.08 * t);
    final curve = s * (-0.085 + 0.18 * t);
    final mouth = ui.Path()
      ..moveTo(center.dx - mouthW / 2, mouthY)
      ..quadraticBezierTo(
        center.dx,
        mouthY + curve * 2,
        center.dx + mouthW / 2,
        mouthY,
      );
    canvas.drawPath(
      mouth,
      Paint()
        ..color = ink.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.042
        ..strokeCap = StrokeCap.round,
    );

    final open = ((t - 0.62) / 0.38).clamp(0.0, 1.0);
    if (open > 0) {
      final openPath = ui.Path()
        ..moveTo(center.dx - mouthW / 2, mouthY)
        ..quadraticBezierTo(
          center.dx,
          mouthY + curve * 2,
          center.dx + mouthW / 2,
          mouthY,
        )
        ..quadraticBezierTo(
          center.dx,
          mouthY + s * 0.15,
          center.dx - mouthW / 2,
          mouthY,
        )
        ..close();
      canvas.drawPath(
        openPath,
        Paint()..color = ink.withValues(alpha: 0.9 * open),
      );
      canvas.save();
      canvas.clipPath(openPath);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, mouthY + s * 0.12),
          width: mouthW * 0.5,
          height: s * 0.08,
        ),
        Paint()..color = const Color(0xFFFF7B83).withValues(alpha: 0.85 * open),
      );
      canvas.restore();
    }

    final sparkle = ((t - 0.78) / 0.22).clamp(0.0, 1.0);
    if (sparkle > 0) {
      _drawSparkle(
        canvas,
        center.translate(s * 0.3, -s * 0.3),
        s * 0.055,
        sparkle,
      );
    }
  }

  void _drawSparkle(
    Canvas canvas,
    Offset center,
    double size,
    double opacity,
  ) {
    canvas.drawLine(
      center.translate(-size, 0),
      center.translate(size, 0),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * opacity)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size * 0.28,
    );
    canvas.drawLine(
      center.translate(0, -size),
      center.translate(0, size),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.9 * opacity)
        ..strokeCap = StrokeCap.round
        ..strokeWidth = size * 0.28,
    );
    final small = size * 0.5;
    final diagonal = Paint()
      ..color = Colors.white.withValues(alpha: 0.55 * opacity)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size * 0.18;
    canvas.drawLine(
      center.translate(-small, -small),
      center.translate(small, small),
      diagonal,
    );
    canvas.drawLine(
      center.translate(small, -small),
      center.translate(-small, small),
      diagonal,
    );
  }

  @override
  bool shouldRepaint(covariant _MoodFacePainter oldDelegate) {
    return oldDelegate.mood != mood || oldDelegate.color != color;
  }
}
