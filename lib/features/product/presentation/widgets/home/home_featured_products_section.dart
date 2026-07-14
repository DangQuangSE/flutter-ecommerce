import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/core/utils/price_formatter.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/shared/product_tactile_card.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

class HomeFeaturedProductsSection extends StatelessWidget {
  final List<ProductEntity> products;

  const HomeFeaturedProductsSection({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingLg,
        vertical: AppSizes.paddingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppStrings.productHomeFeaturedTitle,
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              GestureDetector(
                onTap: () => context.goNamed(AppRoutes.productList),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      AppStrings.productHomeViewAll,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (products.isEmpty)
            const FeaturedProductsEmptyState()
          else ...[
            FeaturedHeroProductCard(product: products[0]),
            const SizedBox(height: 16),
            FeaturedProductRows(products: products.skip(1).take(4).toList()),
          ],
        ],
      ),
    );
  }
}

class FeaturedHeroProductCard extends StatefulWidget {
  final ProductEntity product;

  const FeaturedHeroProductCard({super.key, required this.product});

  @override
  State<FeaturedHeroProductCard> createState() =>
      _FeaturedHeroProductCardState();
}

class _FeaturedHeroProductCardState extends State<FeaturedHeroProductCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        context.pushNamed(
          AppRoutes.productDetail,
          pathParameters: {'productId': widget.product.id},
        );
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color ?? Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF334155).withValues(alpha: 0.5)
                  : Theme.of(context).dividerColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              Container(
                width: 140,
                height: 160,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.product.imageUrl.isNotEmpty)
                      Image.network(
                        widget.product.imageUrl,
                        fit: BoxFit.cover,
                      )
                    else
                      const Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'MỚI NHẤT',
                          style: GoogleFonts.spaceMono(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.product.brandName.toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            widget.product.averageRating.toStringAsFixed(1),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.lexend(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF1A1A2E),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatPrice(widget.product.price),
                            style: GoogleFonts.spaceMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeaturedProductRows extends StatelessWidget {
  final List<ProductEntity> products;

  const FeaturedProductRows({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var index = 0; index < products.length; index += 2) {
      final firstProduct = products[index];
      final secondProduct =
          index + 1 < products.length ? products[index + 1] : null;
      rows.add(FeaturedProductRow(
        firstProduct: firstProduct,
        secondProduct: secondProduct,
      ));
      if (index + 2 < products.length) {
        rows.add(AppSizes.spacingMd);
      }
    }
    return Column(children: rows);
  }
}

class FeaturedProductRow extends StatelessWidget {
  final ProductEntity firstProduct;
  final ProductEntity? secondProduct;

  const FeaturedProductRow({
    super.key,
    required this.firstProduct,
    required this.secondProduct,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: ProductTactileCard(product: firstProduct)),
        AppSizes.spacingMd,
        Expanded(
          child: secondProduct != null
              ? ProductTactileCard(product: secondProduct!)
              : const SizedBox(),
        ),
      ],
    );
  }
}

class FeaturedProductsEmptyState extends StatelessWidget {
  const FeaturedProductsEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Text(
          AppStrings.productHomeFeaturedEmpty,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontLg,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
