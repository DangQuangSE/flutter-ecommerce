import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/product_tactile_card.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

class ProductListGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductListGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const _ProductListEmptyState();
    }

    final columns = _ProductColumns.from(products);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ProductColumn(products: columns.first)),
        AppSizes.spacingMd,
        Expanded(child: _ProductColumn(products: columns.second)),
      ],
    );
  }
}

class _ProductColumn extends StatelessWidget {
  final List<ProductEntity> products;

  const _ProductColumn({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: products
          .map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.paddingMd),
              child: ProductTactileCard(product: product),
            ),
          )
          .toList(),
    );
  }
}

class _ProductListEmptyState extends StatelessWidget {
  const _ProductListEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      padding: AppSizes.screenPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.paddingXl),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.category_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          AppSizes.spacingMd,
          Text(
            AppStrings.productCatalogEmpty,
            style: GoogleFonts.lexend(
              color: AppColors.textPrimary,
              fontSize: AppSizes.submitButtonFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.radiusSm),
          Text(
            AppStrings.productListEmptySubtitle,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textSecondary,
              fontSize: AppSizes.fontMd,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProductColumns {
  final List<ProductEntity> first;
  final List<ProductEntity> second;

  const _ProductColumns({
    required this.first,
    required this.second,
  });

  factory _ProductColumns.from(List<ProductEntity> products) {
    final first = <ProductEntity>[];
    final second = <ProductEntity>[];
    for (var index = 0; index < products.length; index++) {
      if (index.isEven) {
        first.add(products[index]);
      } else {
        second.add(products[index]);
      }
    }
    return _ProductColumns(first: first, second: second);
  }
}
