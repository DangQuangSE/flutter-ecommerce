import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class ProductCarousel extends StatefulWidget {
  final String imageUrl;
  const ProductCarousel({super.key, required this.imageUrl});

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  int _currentCarouselIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.8, // 4:5 mobile crop
      child: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
            children: [
              // Slide 1: Main Product Image
              Container(
                color: const Color(0xFFF3F3F8),
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.image_not_supported_outlined,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              // Slide 2: Zoomed Outsole Details
              Container(
                color: const Color(0xFFE8E8ED),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CHI TIẾT ĐẾ GIÀY',
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Carousel Dot Indicators
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (index) {
                final isCurrent = _currentCarouselIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isCurrent ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: isCurrent
                        ? AppColors.primary
                        : const Color(0xFFC1C6D7).withValues(alpha: 0.5),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
