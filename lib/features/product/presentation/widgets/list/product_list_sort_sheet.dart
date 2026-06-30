import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/list/product_list_filter_option.dart';

Future<ProductListSortOption?> showProductListSortSheet({
  required BuildContext context,
  required ProductListSortOption selectedSort,
}) {
  return showModalBottomSheet<ProductListSortOption>(
    context: context,
    backgroundColor: AppColors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppSizes.paddingXl),
      ),
    ),
    builder: (context) => _ProductListSortSheet(selectedSort: selectedSort),
  );
}

class _ProductListSortSheet extends StatefulWidget {
  final ProductListSortOption selectedSort;

  const _ProductListSortSheet({required this.selectedSort});

  @override
  State<_ProductListSortSheet> createState() => _ProductListSortSheetState();
}

class _ProductListSortSheetState extends State<_ProductListSortSheet> {
  late ProductListSortOption _localSort;

  @override
  void initState() {
    super.initState();
    _localSort = widget.selectedSort;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingXl,
          AppSizes.radiusLg,
          AppSizes.paddingXl,
          AppSizes.paddingXl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SortSheetHandle(),
            AppSizes.spacingLg,
            Text(
              AppStrings.productListFilterAndSort,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.paddingLg,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            AppSizes.spacingLg,
            Text(
              AppStrings.productListSortByPrice,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.radiusMd,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 1.0,
              ),
            ),
            AppSizes.spacingSm,
            ...ProductListSortOption.values.map(
              (option) => _SortOptionTile(
                option: option,
                selected: _localSort == option,
                onTap: () => setState(() => _localSort = option),
              ),
            ),
            AppSizes.spacingLg,
            _SortSheetActions(
              onReset: () {
                setState(() => _localSort = ProductListSortOption.none);
              },
              onApply: () => Navigator.pop(context, _localSort),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortSheetHandle extends StatelessWidget {
  const _SortSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: AppSizes.paddingXs,
        decoration: BoxDecoration(
          color: AppColors.divider,
          borderRadius: BorderRadius.circular(AppSizes.paddingXs),
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final ProductListSortOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSizes.radiusLg,
          horizontal: AppSizes.paddingSm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              option.sheetLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.forgotPasswordFontSize,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? AppColors.accent : AppColors.textPrimary,
              ),
            ),
            _SortSelectionIndicator(selected: selected),
          ],
        ),
      ),
    );
  }
}

class _SortSelectionIndicator extends StatelessWidget {
  final bool selected;

  const _SortSelectionIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.fontXxl,
      height: AppSizes.fontXxl,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.accent : AppColors.divider,
          width: 2,
        ),
        color: selected ? AppColors.accent : Colors.transparent,
      ),
      child: selected
          ? const Center(
              child: Icon(
                Icons.check,
                size: AppSizes.radiusMd,
                color: AppColors.white,
              ),
            )
          : null,
    );
  }
}

class _SortSheetActions extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;

  const _SortSheetActions({
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReset,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.divider),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.fontLg),
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSizes.fontLg),
            ),
            child: Text(
              AppStrings.productFilterReset,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.forgotPasswordFontSize,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.radiusLg),
        Expanded(
          child: ElevatedButton(
            onPressed: onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.fontLg),
              ),
              padding: const EdgeInsets.symmetric(vertical: AppSizes.fontLg),
              minimumSize: Size.zero,
            ),
            child: Text(
              AppStrings.productFilterApply,
              style: GoogleFonts.plusJakartaSans(
                fontSize: AppSizes.forgotPasswordFontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
