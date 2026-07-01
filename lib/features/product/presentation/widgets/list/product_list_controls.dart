import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_filter_option.dart';

class ProductListCategoryChips extends StatelessWidget {
  final List<ProductListCategoryOption> categories;
  final ProductListCategoryOption selectedCategory;
  final ValueChanged<ProductListCategoryOption> onCategorySelected;

  const ProductListCategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: AppSizes.paddingSm),
            child: _CategoryChip(
              category: category,
              selected: category.label == selectedCategory.label,
              onTap: () => onCategorySelected(category),
            ),
          );
        },
      ),
    );
  }
}

class ProductListActionRow extends StatelessWidget {
  final ProductListSortOption selectedSort;
  final VoidCallback onSortTap;

  const ProductListActionRow({
    super.key,
    required this.selectedSort,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionChipButton(
              label: AppStrings.productListBack,
              icon: Icons.arrow_back_rounded,
              iconFirst: true,
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.home);
                }
              },
            ),
            _ActionChipButton(
              label: selectedSort == ProductListSortOption.none
                  ? AppStrings.productFilterTitle
                  : selectedSort.label,
              icon: Icons.tune_rounded,
              onTap: onSortTap,
            ),
          ],
        ),
        const SizedBox(height: AppSizes.radiusLg),
      ],
    );
  }
}

class _ActionChipButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool iconFirst;
  final VoidCallback onTap;

  const _ActionChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        fontSize: AppSizes.fontSm,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
    final iconWidget = Icon(
      icon,
      size: AppSizes.fontXl,
      color: AppColors.textPrimary,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.radiusLg,
          vertical: AppSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: iconFirst
              ? [iconWidget, AppSizes.spacingXs, labelWidget]
              : [labelWidget, AppSizes.spacingXs, iconWidget],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final ProductListCategoryOption category;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMd,
          vertical: AppSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.textPrimary : AppColors.divider,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.08),
                    blurRadius: AppSizes.paddingSm,
                    offset: const Offset(0, AppSizes.paddingXs),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            category.label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSizes.fontSm,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
              color: selected ? AppColors.white : AppColors.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}
