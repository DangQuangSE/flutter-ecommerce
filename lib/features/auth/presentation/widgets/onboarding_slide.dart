import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class OnboardingSlide extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final double scrollOffset; // Used for parallax effect

  const OnboardingSlide({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.scrollOffset,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spacious margin at top to let it breathe
          const SizedBox(height: 60),

          // Header Text (Artistic Asymmetry: Left-aligned offset)
          // Wide horizontal layout with exact 2-3 lines constraint
          SizedBox(
            width: size.width * 0.85,
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                height: 1.1,
                letterSpacing: -1.2,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Double-Bezel Card Enclosure (Principal UI/UX Architect-tier)
          Container(
            // Outer Shell
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.05),
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.all(8.0), // Concentric offset padding
            child: Container(
              // Inner Core
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16), // Concentric inner curve
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Text(
                description,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  height: 1.6,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Asymmetric Overlapping Image with Parallax translation
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -16 - (scrollOffset * 40), // Parallax scroll translation
                  bottom: -10,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(0.06)
                      ..rotateZ(-0.06),
                    alignment: Alignment.center,
                    child: Container(
                      width: size.width * 0.72,
                      height: size.height * 0.32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            blurRadius: 28,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.blue.withValues(alpha: 0.06),
                            BlendMode.colorBurn,
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[100],
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
