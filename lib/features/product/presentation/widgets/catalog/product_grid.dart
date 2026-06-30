import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/product_tactile_card.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductCatalogEntity> products;
  final bool isLoadingMore;
  final VoidCallback? onClearFilters;

  const ProductGrid({
    super.key,
    required this.products,
    this.isLoadingMore = false,
    this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return _EmptyState(onClear: onClearFilters);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.radiusLg,
        mainAxisSpacing: AppSizes.radiusLg,
        childAspectRatio: 0.53,
      ),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.paddingMd),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return ProductTactileCard.fromCatalog(product: products[index]);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onClear;

  const _EmptyState({this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.iconXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_off_rounded,
              size: AppSizes.iconXl,
              color: AppColors.textHint,
            ),
            AppSizes.spacingMd,
            const Text(
              AppStrings.productCatalogEmpty,
              style: TextStyle(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (onClear != null) ...[
              AppSizes.spacingMd,
              TextButton(
                onPressed: onClear,
                child: const Text(AppStrings.productCatalogClearFilter),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
