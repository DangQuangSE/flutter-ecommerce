import 'package:flutter/material.dart';

class BreathingPulseDot extends StatefulWidget {
  final Color color;

  const BreathingPulseDot({super.key, required this.color});

  @override
  State<BreathingPulseDot> createState() => _BreathingPulseDotState();
}

class _BreathingPulseDotState extends State<BreathingPulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
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
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 10 + (8 * _controller.value),
              height: 10 + (8 * _controller.value),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color
                    .withValues(alpha: 0.5 * (1.0 - _controller.value)),
              ),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color,
              ),
            ),
          ],
        );
      },
    );
  }
}
