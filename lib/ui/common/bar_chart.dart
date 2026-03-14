import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A simple, premium-looking vertical bar chart using CustomPainter.
class SimpleBarChart extends StatelessWidget {
  final List<BarData> data;
  final double height;
  final Color barColor;
  final Color? secondaryBarColor;
  final bool showValues;

  const SimpleBarChart({
    super.key,
    required this.data,
    this.height = 200,
    this.barColor = const Color(0xFF60A5FA),
    this.secondaryBarColor,
    this.showValues = true,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: height,
      child: CustomPaint(
        size: Size.infinite,
        painter: _BarChartPainter(
          data: data,
          barColor: barColor,
          secondaryBarColor: secondaryBarColor,
          showValues: showValues,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<BarData> data;
  final Color barColor;
  final Color? secondaryBarColor;
  final bool showValues;
  final bool isDark;

  _BarChartPainter({
    required this.data,
    required this.barColor,
    this.secondaryBarColor,
    required this.showValues,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal = data.map((d) => d.value + (d.secondaryValue ?? 0)).reduce(math.max);
    if (maxVal <= 0) return;

    final bottomPadding = 24.0;
    final topPadding = showValues ? 20.0 : 8.0;
    final chartHeight = size.height - bottomPadding - topPadding;
    final barWidth = (size.width / data.length) * 0.55;
    final gap = (size.width / data.length);

    for (int i = 0; i < data.length; i++) {
      final x = i * gap + (gap - barWidth) / 2;
      final totalVal = data[i].value + (data[i].secondaryValue ?? 0);
      final barHeight = (totalVal / maxVal) * chartHeight;

      // Primary bar
      final primaryHeight = (data[i].value / maxVal) * chartHeight;
      final primaryRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          x,
          topPadding + chartHeight - barHeight,
          barWidth,
          primaryHeight,
        ),
        topLeft: secondaryBarColor != null
            ? Radius.zero
            : const Radius.circular(6),
        topRight: secondaryBarColor != null
            ? Radius.zero
            : const Radius.circular(6),
      );

      final primaryPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            barColor,
            barColor.withOpacity(0.6),
          ],
        ).createShader(primaryRect.outerRect);

      canvas.drawRRect(primaryRect, primaryPaint);

      // Secondary bar (stacked on top)
      if (secondaryBarColor != null && (data[i].secondaryValue ?? 0) > 0) {
        final secondaryHeight =
            ((data[i].secondaryValue ?? 0) / maxVal) * chartHeight;
        final secondaryRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(
            x,
            topPadding + chartHeight - barHeight,
            barWidth,
            secondaryHeight,
          ),
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        );

        final secondaryPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              secondaryBarColor!,
              secondaryBarColor!.withOpacity(0.6),
            ],
          ).createShader(secondaryRect.outerRect);

        canvas.drawRRect(secondaryRect, secondaryPaint);
      }

      // Label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: data[i].label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: gap);
      labelPainter.paint(
        canvas,
        Offset(x + (barWidth - labelPainter.width) / 2,
            size.height - bottomPadding + 4),
      );

      // Value on top
      if (showValues && totalVal > 0) {
        final valueStr = _formatCompact(totalVal);
        final valuePainter = TextPainter(
          text: TextSpan(
            text: valueStr,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: gap);
        valuePainter.paint(
          canvas,
          Offset(
            x + (barWidth - valuePainter.width) / 2,
            topPadding + chartHeight - barHeight - 14,
          ),
        );
      }
    }
  }

  String _formatCompact(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarData {
  final String label;
  final double value;
  final double? secondaryValue;

  const BarData({
    required this.label,
    required this.value,
    this.secondaryValue,
  });
}
