import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class ProductCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const ProductCarousel({super.key, required this.imageUrls});

  @override
  State<ProductCarousel> createState() => _ProductCarouselState();
}

class _ProductCarouselState extends State<ProductCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    if (urls.isEmpty) {
      return AspectRatio(
        aspectRatio: 0.8,
        child: Container(
          color: const Color(0xFFF3F3F8),
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 0.8,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (_, i) => CachedNetworkImage(
              imageUrl: urls[i],
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(color: Color(0xFFF3F3F8)),
              errorWidget: (_, __, ___) => const ColoredBox(
                color: Color(0xFFF3F3F8),
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (i) {
                  final isCurrent = _currentIndex == i;
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
