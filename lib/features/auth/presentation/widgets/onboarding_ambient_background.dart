import 'dart:ui';
import 'package:flutter/material.dart';

class OnboardingAmbientBackground extends StatelessWidget {
  final double scrollOffset;

  const OnboardingAmbientBackground({
    super.key,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Glowing highlight colors for each slide stage (Electric Blue, Deep Purple, Electric Orange)
    final List<Color> glowColors = [
      const Color(0xFF1D4ED8), // Slide 0: Blue glow
      const Color(0xFF6D28D9), // Slide 1: Purple glow
      const Color(0xFFC2410C), // Slide 2: Orange glow
    ];

    // Compute active color interpolation based on scrolling
    final int index1 = scrollOffset.floor().clamp(0, 2);
    final int index2 = scrollOffset.ceil().clamp(0, 2);
    final double t = (scrollOffset - index1).clamp(0.0, 1.0);
    final Color activeGlowColor = Color.lerp(glowColors[index1], glowColors[index2], t) ?? glowColors[0];

    return Stack(
      children: [
        // 1. Deep Dark Base Gradient (matching screenshot vibe)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F1020), // Deep blue-violet charcoal
                Color(0xFF040408), // Near-black charcoal
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // 2. Centered/Bottom Glowing Ambient Sphere (illuminating the 3D graphics)
        Positioned(
          top: size.height * 0.28,
          left: size.width * 0.1,
          right: size.width * 0.1,
          child: Container(
            height: size.height * 0.38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: activeGlowColor.withValues(alpha: 0.24), // Dynamic glowing color
            ),
          ),
        ),

        // 3. High blur filter to blend the sphere into a perfect ambient backdrop glow
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // 4. Subtle micro-dot texture overlay
        const Positioned.fill(
          child: CustomPaint(
            painter: _DottedGridPainter(),
          ),
        ),
      ],
    );
  }
}

class _DottedGridPainter extends CustomPainter {
  const _DottedGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.015)
      ..style = PaintingStyle.fill;

    const spacing = 28.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.7, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
