import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A simple donut chart using CustomPainter.
class DonutSegment {
  final String label;
  final double value;
  final Color color;

  const DonutSegment({
    required this.label,
    required this.value,
    required this.color,
  });
}

class _DonutChartPainter extends CustomPainter {
  final List<DonutSegment> segments;
  final bool isDark;
  final double animationValue;

  _DonutChartPainter({
    required this.segments, 
    required this.isDark,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final total = segments.fold(0.0, (sum, s) => sum + s.value);
    if (total <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = radius * 0.32;

    double startAngle = -math.pi / 2; // Start from top

    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * 2 * math.pi * animationValue;

      if (sweepAngle <= 0) continue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = segment.color;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.02, // Small gap between segments
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => 
      oldDelegate.animationValue != animationValue || oldDelegate.segments != segments;
}

class DonutChart extends StatefulWidget {
  final List<DonutSegment> segments;
  final double size;
  final String? centerLabel;
  final String? centerValue;

  const DonutChart({
    super.key,
    required this.segments,
    this.size = 160,
    this.centerLabel,
    this.centerValue,
  });

  @override
  State<DonutChart> createState() => _DonutChartState();
}

class _DonutChartState extends State<DonutChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _DonutChartPainter(
                  segments: widget.segments,
                  isDark: isDark,
                  animationValue: _animation.value,
                ),
              ),
              if (widget.centerLabel != null || widget.centerValue != null)
                Opacity(
                  opacity: _animation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.centerValue != null)
                        Text(
                          widget.centerValue!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      if (widget.centerLabel != null)
                        Text(
                          widget.centerLabel!,
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
