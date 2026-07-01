import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class AppLoadingView extends StatefulWidget {
  final double? size;
  final Color color;

  const AppLoadingView({
    super.key,
    this.size,
    this.color = AppColors.primary,
  });

  @override
  State<AppLoadingView> createState() => _AppLoadingViewState();
}

class _AppLoadingViewState extends State<AppLoadingView> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.85,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double defaultSize = widget.size ?? 64;

    return Center(
      child: SizedBox(
        width: defaultSize,
        height: defaultSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Rotating gradient progress ring
            AnimatedBuilder(
              animation: _rotationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationController.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(defaultSize, defaultSize),
                    painter: _GradientRingPainter(color: widget.color),
                  ),
                );
              },
            ),
            // Pulsing Sport Pro logo in the center
            ScaleTransition(
              scale: _pulseController,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(defaultSize),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: defaultSize * 0.52,
                  height: defaultSize * 0.52,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback to dynamic neon bolt icon if logo image fails to load
                    return Icon(
                      Icons.flash_on_rounded,
                      size: defaultSize * 0.5,
                      color: widget.color,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  final Color color;

  _GradientRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          color.withValues(alpha: 0.05),
          color,
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);

    // Draw the gradient arc (slightly open to look like a premium spinner)
    canvas.drawArc(rect, 0, 1.9 * math.pi, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
