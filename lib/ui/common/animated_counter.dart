import 'package:flutter/material.dart';
import '../../util/date_utils.dart' as app_date;

class AnimatedCounter extends StatefulWidget {
  final double value;
  final TextStyle? style;
  final Duration duration;
  final Curve curve;
  final String Function(double)? formatter;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 2000),
    this.curve = Curves.elasticOut,
    this.formatter,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldValue = 0;

  @override
  void initState() {
    super.initState();
    _oldValue = 0;
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    
    // Add a small delay so the user can actually see the animation start
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _controller.reset();
      _animation = Tween<double>(begin: _oldValue, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: widget.curve),
      );
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final displayValue = _animation.value;
        final formattedValue = widget.formatter != null 
            ? widget.formatter!(displayValue)
            : app_date.formatCurrencyDouble(displayValue);
            
        // Add a subtle scale effect as it counts
        return Transform.scale(
          scale: 1.0 + (0.05 * _controller.value * (1 - _controller.value) * 4), 
          child: Text(
            formattedValue,
            style: widget.style,
          ),
        );
      },
    );
  }
}
