import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class OnboardingAmbientBackground extends StatelessWidget {
  final double scrollOffset;

  const OnboardingAmbientBackground({
    super.key,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Vibrant theme colors for each slide stage
    final List<Color> primaryColors = [
      const Color(0xFF1A73E8), // Electric Blue
      const Color(0xFF6D28D9), // Purple/Violet
      const Color(0xFFEA580C), // Orange/Sunset
    ];

    final List<Color> accentColors = [
      const Color(0xFF06B6D4), // Cyan/Teal
      const Color(0xFFEC4899), // Pink/Magenta
      const Color(0xFFF59E0B), // Amber/Gold
    ];

    // Calculate continuous interpolation between slides
    final int index1 = scrollOffset.floor().clamp(0, 2);
    final int index2 = scrollOffset.ceil().clamp(0, 2);
    final double t = (scrollOffset - index1).clamp(0.0, 1.0);

    final Color primaryColor = Color.lerp(primaryColors[index1], primaryColors[index2], t) ?? primaryColors[0];
    final Color accentColor = Color.lerp(accentColors[index1], accentColors[index2], t) ?? accentColors[0];

    return Stack(
      children: [
        // Base dark background (neutral base, anti-sterile)
        Container(
          color: AppColors.background,
        ),

        // Ambient moving primary blob
        Positioned(
          top: -size.height * 0.1,
          right: -size.width * 0.25,
          child: Container(
            width: size.width * 0.95,
            height: size.width * 0.95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.16),
            ),
          ),
        ),

        // Ambient moving accent blob (opposite side)
        Positioned(
          bottom: -size.height * 0.12,
          left: -size.width * 0.25,
          child: Container(
            width: size.width * 1.0,
            height: size.width * 1.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withValues(alpha: 0.14),
            ),
          ),
        ),

        // Secondary subtle center glow
        Positioned(
          top: size.height * 0.35,
          left: size.width * 0.2,
          child: Container(
            width: size.width * 0.55,
            height: size.width * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.10),
            ),
          ),
        ),

        // Advanced blur to create organic liquid mesh gradient
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Technical dotted texture overlay for premium athletic feel
        const Positioned.fill(
          child: CustomPaint(
            painter: _DotGridPainter(),
          ),
        ),
      ],
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.8, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
