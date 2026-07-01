import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class AdminVariantActionButtons extends StatelessWidget {
  final VoidCallback onBulkCreate;
  final VoidCallback onAddOne;

  const AdminVariantActionButtons({
    super.key,
    required this.onBulkCreate,
    required this.onAddOne,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSizes.paddingSm),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBulkCreate,
                icon: Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(AppStrings.adminProductVariantCreateBulk),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingSm + 4,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSizes.paddingSm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddOne,
                icon: Icon(Icons.add_rounded, size: 18),
                label: Text(AppStrings.adminProductVariantAddOne),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.divider),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingSm + 4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}

class AdminVariantNavigation extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;

  const AdminVariantNavigation({
    super.key,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingSm,
          AppSizes.paddingMd,
          AppSizes.paddingMd,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onBack,
                icon: Icon(Icons.arrow_back_rounded),
                label: Text(AppStrings.adminProductVariantBack),
              ),
            ),
            SizedBox(width: AppSizes.paddingMd),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: onNext,
                icon: Icon(Icons.arrow_forward_rounded),
                label: Text(AppStrings.adminProductVariantNext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
}
