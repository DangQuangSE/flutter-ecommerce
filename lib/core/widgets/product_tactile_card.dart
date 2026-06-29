import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';

class ProductTactileCard extends StatefulWidget {
  final ProductEntity? product;
  final ProductCatalogEntity? catalogProduct;
  final String? badge;

  const ProductTactileCard({
    super.key,
    required this.product,
    this.badge,
  }) : catalogProduct = null;

  const ProductTactileCard.fromCatalog({
    super.key,
    required ProductCatalogEntity product,
    this.badge,
  })  : product = null,
        catalogProduct = product;

  @override
  State<ProductTactileCard> createState() => _ProductTactileCardState();
}

class _ProductTactileCardState extends State<ProductTactileCard> {
  double _scale = 1.0;

  String get _id => widget.product?.id ?? widget.catalogProduct?.slug ?? '';
  String get _name => widget.product?.name ?? widget.catalogProduct?.name ?? '';
  String get _imageUrl =>
      widget.product?.imageUrl ?? widget.catalogProduct?.imageUrl ?? '';
  String get _brandName =>
      widget.product?.brandName ?? widget.catalogProduct?.brandName ?? '';
  String get _categoryName =>
      widget.product?.categoryName ?? widget.catalogProduct?.categoryName ?? '';

  double get _price => widget.product != null
      ? widget.product!.price
      : (widget.catalogProduct?.salePrice ??
          widget.catalogProduct?.originalPrice ??
          0.0);

  double get _originalPrice =>
      widget.product?.originalPrice ??
      widget.catalogProduct?.originalPrice ??
      0.0;

  double get _averageRating =>
      widget.product?.averageRating ??
      widget.catalogProduct?.averageRating ??
      0.0;

  bool get _hasDiscount => widget.product != null
      ? widget.product!.hasDiscount
      : (widget.catalogProduct?.hasDiscount ?? false);

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _scale = 0.96;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _scale = 1.0;
    });
    context.pushNamed(
      AppRoutes.productDetail,
      pathParameters: {'productId': _id},
    );
  }

  void _onTapCancel() {
    setState(() {
      _scale = 1.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double? originalPrice = _hasDiscount ? _originalPrice : null;
    final int? discountPercent = _hasDiscount
        ? (((_originalPrice - _price) / _originalPrice) * 100).round()
        : null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.fastLinearToSlowEaseIn,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.015),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 0.84,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _imageUrl.isNotEmpty
                          ? Image.network(
                              _imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 28,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 28,
                                color: AppColors.textSecondary,
                              ),
                            ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.badge!,
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            else if (discountPercent != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '-$discountPercent%',
                                  style: GoogleFonts.spaceMono(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            _brandName.toUpperCase(),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Text(
                          _categoryName.toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StarRating(rating: _averageRating),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatPrice(_price),
                            style: GoogleFonts.spaceMono(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (originalPrice != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              _formatPrice(originalPrice),
                              style: GoogleFonts.spaceMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final formatStr = price.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < formatStr.length; i++) {
      buffer.write(formatStr[i]);
      if ((formatStr.length - 1 - i) % 3 == 0 && i != formatStr.length - 1) {
        buffer.write('.');
      }
    }
    return '${buffer.toString()}đ';
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, size: 12, color: Color(0xFFFFC107));
        } else if (i < rating && rating - i >= 0.5) {
          return const Icon(Icons.star_half,
              size: 12, color: Color(0xFFFFC107));
        }
        return const Icon(Icons.star_border,
            size: 12, color: Color(0xFFFFC107));
      }),
    );
  }
}
