import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_controls.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_filter_option.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_grid.dart';

class ProductListContent extends StatelessWidget {
  final double statusBarHeight;
  final List<ProductEntity> products;
  final ProductListCategoryOption selectedCategory;
  final List<ProductListCategoryOption> categories;
  final ProductListSortOption selectedSort;
  final ValueChanged<ProductListCategoryOption> onCategorySelected;
  final VoidCallback onSortTap;

  const ProductListContent({
    super.key,
    required this.statusBarHeight,
    required this.products,
    required this.selectedCategory,
    required this.categories,
    required this.selectedSort,
    required this.onCategorySelected,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppSizes.paddingMd,
        statusBarHeight + 92,
        AppSizes.paddingMd,
        120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProductListHeader(selectedCategory: selectedCategory),
          ProductListActionRow(
            selectedSort: selectedSort,
            onSortTap: onSortTap,
          ),
          ProductListCategoryChips(
            categories: categories,
            selectedCategory: selectedCategory,
            onCategorySelected: onCategorySelected,
          ),
          AppSizes.spacingMd,
          ProductListGrid(products: products),
        ],
      ),
    );
  }
}

class _ProductListHeader extends StatelessWidget {
  final ProductListCategoryOption selectedCategory;

  const _ProductListHeader({required this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final title = selectedCategory.categoryId == null &&
            selectedCategory.label == ProductListCategoryOption.all.label
        ? AppStrings.productListAllProducts
        : selectedCategory.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingXs,
            bottom: AppSizes.paddingSm,
          ),
          child: Text(
            AppStrings.productListCollectionEyebrow,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSizes.radiusMd,
              fontWeight: FontWeight.w800,
              color: AppColors.accent,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: AppSizes.paddingXs,
            bottom: AppSizes.paddingMd,
          ),
          child: Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
