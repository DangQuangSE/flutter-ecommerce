import 'package:flutter/material.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/color_selector.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/detail/product_detail_app_bar.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/detail/product_detail_bottom_action_bar.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/detail/product_detail_divider.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/detail/product_detail_info.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/detail/product_detail_panels.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/product_carousel.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/size_selector.dart';

class ProductDetailContent extends StatelessWidget {
  final ProductEntity product;
  final int selectedColorIndex;
  final String selectedSize;
  final bool isFavorited;
  final ValueChanged<int> onColorSelected;
  final ValueChanged<String> onSizeSelected;
  final VoidCallback onToggleFavorite;
  final void Function(
      ProductVariantEntity? matchingVariant, String selectedSize) onAddToCart;

  const ProductDetailContent({
    super.key,
    required this.product,
    required this.selectedColorIndex,
    required this.selectedSize,
    required this.isFavorited,
    required this.onColorSelected,
    required this.onSizeSelected,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final categoryLabel = product.categoryName.toUpperCase();
    final variants = product.variants ?? [];
    final colorMap = <String, String>{};
    final sizeList = <String>[];

    for (final variant in variants) {
      if (variant.colorName.isNotEmpty) {
        colorMap[variant.colorName] =
            variant.colorHex.isNotEmpty ? variant.colorHex : '#000000';
      }
      if (variant.size.isNotEmpty && !sizeList.contains(variant.size)) {
        sizeList.add(variant.size);
      }
    }

    final colors =
        colorMap.entries.map((e) => {'name': e.key, 'hex': e.value}).toList();
    final sizes = sizeList;
    final safeColorIndex =
        selectedColorIndex.clamp(0, colors.isEmpty ? 0 : colors.length - 1);
    final selectedColor =
        colors.isNotEmpty ? colors[safeColorIndex]['name'] : null;
    final safeSelectedSize = sizes.contains(selectedSize)
        ? selectedSize
        : (sizes.isNotEmpty ? sizes.first : selectedSize);
    final matchingVariant = _findMatchingVariant(
      variants,
      selectedColor,
      safeSelectedSize,
    );
    final priceToDisplay = matchingVariant != null
        ? (matchingVariant.salePrice ?? matchingVariant.originalPrice)
        : product.price;
    final originalPriceToDisplay = matchingVariant != null
        ? (matchingVariant.salePrice != null &&
                matchingVariant.salePrice! < matchingVariant.originalPrice
            ? matchingVariant.originalPrice
            : null)
        : (product.hasDiscount ? product.originalPrice : null);
    final stockToDisplay = matchingVariant != null
        ? matchingVariant.stockQuantity
        : product.stockQuantity;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ProductDetailAppBar(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductCarousel(imageUrls: _imageUrls(product)),
                  ProductDetailInfo(
                    product: product,
                    categoryLabel: categoryLabel,
                    priceToDisplay: priceToDisplay,
                    originalPriceToDisplay: originalPriceToDisplay,
                    formatPrice: _formatPrice,
                  ),
                  if (colors.isNotEmpty) ...[
                    const ProductDetailDivider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ColorSelector(
                        selectedColorIndex: safeColorIndex,
                        colors: colors,
                        onColorSelected: onColorSelected,
                      ),
                    ),
                  ],
                  if (sizes.isNotEmpty) ...[
                    const ProductDetailDivider(),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizeSelector(
                        selectedSize: safeSelectedSize,
                        sizes: sizes,
                        onSizeSelected: onSizeSelected,
                      ),
                    ),
                  ],
                  const ProductDetailDivider(),
                  ProductDetailPanels(product: product),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          ProductDetailBottomActionBar(
            isFavorited: isFavorited,
            isInStock: stockToDisplay > 0,
            onToggleFavorite: onToggleFavorite,
            onAddToCart: () => onAddToCart(matchingVariant, safeSelectedSize),
          ),
        ],
      ),
    );
  }

  ProductVariantEntity? _findMatchingVariant(
    List<ProductVariantEntity> variants,
    String? selectedColor,
    String safeSelectedSize,
  ) {
    if (variants.isEmpty) return null;
    try {
      return variants.firstWhere(
        (v) => v.colorName == selectedColor && v.size == safeSelectedSize,
        orElse: () => variants.firstWhere(
          (v) => v.size == safeSelectedSize,
          orElse: () => variants.first,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  List<String> _imageUrls(ProductEntity product) {
    if (product.imageUrls.isNotEmpty) return product.imageUrls;
    if (product.imageUrl.isNotEmpty) return [product.imageUrl];
    return const [];
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
    return '${buffer.toString()}\u0111';
  }
}
