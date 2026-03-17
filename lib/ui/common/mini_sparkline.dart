import 'package:flutter/material.dart';
import 'dart:ui' as ui;

// MiniSparkline is now a StatefulWidget below for animation

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double pulseValue; // Added for animation

  _SparklinePainter({
    required this.data, 
    required this.color, 
    this.pulseValue = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double stepX = size.width / (data.length - 1);
    final double max = data.reduce((a, b) => a > b ? a : b);
    final double min = data.reduce((a, b) => a < b ? a : b);
    final double range = max - min == 0 ? 1 : max - min;

    final List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final double x = i * stepX;
      final double y = size.height - ((data[i] - min) / range * size.height);
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    // Bezier Curve Logic
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p2.dx, p2.dy,
      );
    }

    // 1. Draw Glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawPath(path, glowPaint);

    // 2. Draw Area Gradient
    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(0, size.height),
        [color.withOpacity(0.2), color.withOpacity(0)],
      );
    canvas.drawPath(fillPath, fillPaint);

    // 3. Draw Main Line
    canvas.drawPath(path, paint);

    // 4. Draw Pulsing Dot at the end
    final lastPoint = points.last;
    
    // Outer pulse
    final pulsePaint = Paint()
      ..color = color.withOpacity(0.4 * (1 - pulseValue))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(lastPoint, 6 + (8 * pulseValue), pulsePaint);
    
    // Static core
    final corePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final coreBorderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
      
    canvas.drawCircle(lastPoint, 4, corePaint);
    canvas.drawCircle(lastPoint, 4, coreBorderPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) => 
      oldDelegate.pulseValue != pulseValue || oldDelegate.data != data;
}

class MiniSparkline extends StatefulWidget {
  final List<double> data;
  final Color color;
  final double height;
  final double width;

  const MiniSparkline({
    super.key,
    required this.data,
    required this.color,
    this.height = 40,
    this.width = 120,
  });

  @override
  State<MiniSparkline> createState() => _MiniSparklineState();
}

class _MiniSparklineState extends State<MiniSparkline> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          height: widget.height,
          width: widget.width,
          child: CustomPaint(
            painter: _SparklinePainter(
              data: widget.data,
              color: widget.color,
              pulseValue: _controller.value,
            ),
          ),
        );
      },
    );
  }
}
