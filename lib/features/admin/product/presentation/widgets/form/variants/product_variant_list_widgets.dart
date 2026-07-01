import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';

class AdminVariantEmptyPlaceholder extends StatelessWidget {
  final bool canAddVariant;

  const AdminVariantEmptyPlaceholder({
    super.key,
    required this.canAddVariant,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXl + 8),
        child: Column(
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: AppSizes.iconXl - AppSizes.paddingMd,
              color: AppColors.textHint,
            ),
            const SizedBox(height: AppSizes.paddingSm + 4),
            const Text(
              AppStrings.adminProductVariantEmptyTitle,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppSizes.submitButtonFontSize,
              ),
            ),
            if (canAddVariant) ...[
              const SizedBox(height: AppSizes.paddingXs + 2),
              const Text(
                AppStrings.adminProductVariantEmptyHint,
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: AppSizes.forgotPasswordFontSize,
                ),
              ),
            ],
          ],
        ),
      );
}

class AdminVariantBasicInfoWarning extends StatelessWidget {
  const AdminVariantBasicInfoWarning({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSizes.paddingSm + 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSm + 2),
          border: Border.all(color: AppColors.warning),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppColors.warning,
              size: AppSizes.iconSm,
            ),
            SizedBox(width: AppSizes.paddingSm),
            Expanded(
              child: Text(
                AppStrings.adminProductVariantBasicInfoRequired,
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: AppSizes.forgotPasswordFontSize,
                ),
              ),
            ),
          ],
        ),
      );
}

class AdminVariantRow extends StatelessWidget {
  final ProductVariantEntity variant;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminVariantRow({
    super.key,
    required this.variant,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingSm),
        child: ListTile(
          title: Text(
            variant.sku,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(subtitle),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.adminProductVariantStockUnit(variant.stockQuantity),
                style: const TextStyle(
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textSecondary,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                ),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      );
}
