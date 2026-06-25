import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingSlide extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final String imageUrl;
  final double scrollOffset;

  const OnboardingSlide({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Glowing colors matching each slide stage
    final List<Color> themeColors = [
      const Color(0xFF1D4ED8), // Slide 0: Blue glow
      const Color(0xFF6D28D9), // Slide 1: Purple glow
      const Color(0xFFC2410C), // Slide 2: Orange glow
    ];
    final Color activeColor = themeColors[index.clamp(0, 2)];

    // Calculate dynamic 3D perspective rotation offsets based on horizontal scroll progress
    final double tiltX = scrollOffset * 0.08;
    final double tiltY = -scrollOffset * 0.15;
    final double tiltZ = scrollOffset * 0.03;

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Upper offset to position content nicely below the notch/status bar
          SizedBox(height: size.height * 0.08),

          // 1. Centered Title (Lexend to fix Vietnamese diacritics)
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lexend(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              height: 1.2,
              letterSpacing: -0.8,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // 2. Centered Description (Inter for perfect Vietnamese diacritics)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            constraints: BoxConstraints(maxWidth: size.width * 0.85),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.0,
                height: 1.5,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // 3. Floating 3D Graphic Area in the center
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // A. Floor Shadow/Reflective platform under the image
                    Positioned(
                      bottom: -22,
                      child: Container(
                        width: size.width * 0.45,
                        height: 14,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.35),
                              blurRadius: 22,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // B. Main 3D graphic container with coordinate tilt rotation
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateX(tiltX)
                        ..rotateY(tiltY)
                        ..rotateZ(tiltZ),
                      alignment: Alignment.center,
                      child: Container(
                        width: size.width * 0.65,
                        height: size.height * 0.30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: activeColor.withValues(alpha: 0.12),
                              blurRadius: 36,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              activeColor.withValues(alpha: 0.04),
                              BlendMode.colorBurn,
                            ),
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: const Color(0xFF0F1020),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFF1E293B),
                                  child: const Icon(
                                    Icons.blur_on_outlined,
                                    size: 44,
                                    color: Colors.white24,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Spacing corresponding to the height of bottom indicators/buttons
          SizedBox(height: size.height * 0.22),
        ],
      ),
    );
  }
}
