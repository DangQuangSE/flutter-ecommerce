import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

class ProductDetailInfo extends StatelessWidget {
  final ProductEntity product;
  final String categoryLabel;
  final double priceToDisplay;
  final double? originalPriceToDisplay;
  final String Function(double price) formatPrice;

  const ProductDetailInfo({
    super.key,
    required this.product,
    required this.categoryLabel,
    required this.priceToDisplay,
    required this.originalPriceToDisplay,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductBrandRow(product: product, categoryLabel: categoryLabel),
          SizedBox(height: 6),
          Text(
            product.name,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _ProductPriceBlock(
                priceToDisplay: priceToDisplay,
                originalPriceToDisplay: originalPriceToDisplay,
                formatPrice: formatPrice,
              ),
              _ProductRatingBlock(product: product),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductBrandRow extends StatelessWidget {
  final ProductEntity product;
  final String categoryLabel;

  const _ProductBrandRow({
    required this.product,
    required this.categoryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            product.brandName.toUpperCase(),
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Text(
          categoryLabel,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ProductPriceBlock extends StatelessWidget {
  final double priceToDisplay;
  final double? originalPriceToDisplay;
  final String Function(double price) formatPrice;

  const _ProductPriceBlock({
    required this.priceToDisplay,
    required this.originalPriceToDisplay,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (originalPriceToDisplay != null)
              Text(
                formatPrice(originalPriceToDisplay!),
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Transform(
              transform: Matrix4.skewX(-0.12),
              child: Text(
                formatPrice(priceToDisplay),
                style: GoogleFonts.lexend(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        if (originalPriceToDisplay != null &&
            originalPriceToDisplay! > priceToDisplay) ...[
          SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Gi\u1ea3m ${(((originalPriceToDisplay! - priceToDisplay) / originalPriceToDisplay!) * 100).round()}%',
              style: GoogleFonts.spaceMono(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProductRatingBlock extends StatelessWidget {
  final ProductEntity product;

  const _ProductRatingBlock({required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.reviewCount <= 0) {
      return Text(
        AppStrings.noRatingYet,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      );
    }

    return Row(
      children: [
        Row(children: _buildRatingStars(product.averageRating)),
        SizedBox(width: 4),
        Text(
          AppStrings.productReviewCount(product.reviewCount),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRatingStars(double rating) {
    return List.generate(5, (index) {
      final remainder = rating - index;
      final icon = remainder >= 1
          ? Icons.star_rounded
          : remainder >= 0.5
              ? Icons.star_half_rounded
              : Icons.star_outline_rounded;
      return Icon(icon, color: AppColors.accent, size: 18);
    });
  }
}
