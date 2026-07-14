import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/widgets/fade_up_entrance.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/home/product_home_hero_section.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/home/home_category_section.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/home/home_featured_products_section.dart';

class ProductHomeContent extends StatelessWidget {
  final List<ProductEntity> products;
  final double statusBarHeight;

  const ProductHomeContent({
    super.key,
    required this.products,
    required this.statusBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        // Background Glowing Orbs (Ethereal Glass archetype)
        if (isDark) ...[
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned(
            top: 250,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ],
        // Main content list
        ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(0, statusBarHeight + 92, 0, 120),
          children: [
            const ProductHomeHeroSection(),
            FadeUpEntrance(
              delay: const Duration(milliseconds: 200),
              child: const HomeCategorySection(),
            ),
            FadeUpEntrance(
              delay: const Duration(milliseconds: 400),
              child: HomeFeaturedProductsSection(products: products),
            ),
          ],
        ),
      ],
    );
  }
}
