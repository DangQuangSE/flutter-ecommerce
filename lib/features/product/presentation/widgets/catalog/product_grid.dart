import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_catalog_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_card.dart';

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
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.50,
      ),
      itemCount: products.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return ProductCard(product: products[index]);
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
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 16),
            const Text(
              'Không tìm thấy sản phẩm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            if (onClear != null) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: onClear,
                child: const Text('Xóa bộ lọc'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
