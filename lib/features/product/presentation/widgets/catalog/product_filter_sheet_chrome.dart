import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class ProductFilterSheetHandle extends StatelessWidget {
  const ProductFilterSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.paddingLg),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
    );
  }
}

class ProductFilterSheetHeader extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onClose;

  const ProductFilterSheetHeader({
    super.key,
    required this.onReset,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingLg,
        AppSizes.paddingMd,
        AppSizes.paddingMd,
        0,
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primary),
          AppSizes.spacingSm,
          const Expanded(
            child: Text(
              AppStrings.productFilterTitle,
              style: TextStyle(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onReset,
            child: const Text(
              AppStrings.productFilterClearAll,
              style: TextStyle(color: AppColors.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class ProductFilterSheetActions extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;

  const ProductFilterSheetActions({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingLg,
          AppSizes.paddingSm,
          AppSizes.paddingLg,
          AppSizes.paddingMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
                child: const Text(AppStrings.productFilterReset),
              ),
            ),
            AppSizes.spacingMd,
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
                child: const Text(
                  AppStrings.productFilterApply,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
