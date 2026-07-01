import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/params/create_variant_params.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/widgets/bulk_variant/bulk_variant_helpers.dart';
import 'package:flutter_ecommerce/features/color/domain/entities/product_color_entity.dart';

class BulkVariantPreviewSection extends StatelessWidget {
  final List<CreateVariantParams> preview;
  final List<ProductColorEntity> colors;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onEdit;

  const BulkVariantPreviewSection({
    super.key,
    required this.preview,
    required this.colors,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PreviewHeader(count: preview.length),
          SizedBox(height: AppSizes.paddingSm),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: preview.length,
            separatorBuilder: (_, __) =>
                SizedBox(height: AppSizes.paddingXs + 2),
            itemBuilder: (_, index) {
              final item = preview[index];
              final color = colors
                      .where((color) => color.id == item.colorId)
                      .firstOrNull ??
                  const ProductColorEntity(name: '?', hexCode: '#999999');
              return _PreviewItemCard(
                item: item,
                color: color,
                onRemove: () => onRemove(index),
                onEdit: () => onEdit(index),
              );
            },
          ),
        ],
      );
}

class BulkVariantBottomActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;
  final int count;

  const BulkVariantBottomActions({
    super.key,
    required this.onCancel,
    required this.onConfirm,
    required this.count,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingMd,
          AppSizes.paddingSm,
          AppSizes.paddingMd,
          AppSizes.paddingMd,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancel,
                child: Text(AppStrings.cancel),
              ),
            ),
            SizedBox(width: AppSizes.radiusLg),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onConfirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSizes.radiusLg),
                ),
                child: Text(
                  count > 0
                      ? AppStrings.adminProductBulkConfirmSaveCount(count)
                      : AppStrings.adminProductBulkConfirmSave,
                ),
              ),
            ),
          ],
        ),
      );
}

class _PreviewHeader extends StatelessWidget {
  final int count;

  const _PreviewHeader({required this.count});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const BulkVariantSectionLabel(AppStrings.adminProductBulkPreview),
          SizedBox(width: AppSizes.paddingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            ),
            child: Text(
              AppStrings.adminProductBulkVariantCount(count),
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
}

class _PreviewItemCard extends StatelessWidget {
  final CreateVariantParams item;
  final ProductColorEntity color;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  const _PreviewItemCard({
    required this.item,
    required this.color,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.radiusLg,
          vertical: AppSizes.paddingSm,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(
          children: [
            _ColorDot(hexCode: color.hexCode),
            _SizeBadge(size: item.size),
            SizedBox(width: AppSizes.paddingSm),
            Expanded(child: _VariantInfo(colorName: color.name, sku: item.sku)),
            _PriceDisplay(
              originalPrice: item.originalPrice,
              salePrice: item.salePrice,
            ),
            _CardAction(
              icon: Icons.edit_outlined,
              color: AppColors.primary,
              size: AppSizes.iconSm + 2,
              tooltip: AppStrings.edit,
              onTap: onEdit,
            ),
            _CardAction(
              icon: Icons.remove_circle_outline_rounded,
              color: AppColors.error,
              size: AppSizes.iconMd,
              onTap: onRemove,
            ),
          ],
        ),
      );
}

class _ColorDot extends StatelessWidget {
  final String hexCode;

  const _ColorDot({required this.hexCode});

  @override
  Widget build(BuildContext context) => Container(
        width: AppSizes.radiusLg,
        height: AppSizes.radiusLg,
        margin: const EdgeInsets.only(right: AppSizes.paddingSm),
        decoration: BoxDecoration(
          color: bulkVariantHexColor(hexCode),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.divider),
        ),
      );
}

class _SizeBadge extends StatelessWidget {
  final String size;

  const _SizeBadge({required this.size});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.radiusSm,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Text(
          size,
          style: TextStyle(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class _VariantInfo extends StatelessWidget {
  final String colorName;
  final String sku;

  const _VariantInfo({required this.colorName, required this.sku});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            colorName,
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            sku,
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
}

class _PriceDisplay extends StatelessWidget {
  final double originalPrice;
  final double? salePrice;

  const _PriceDisplay({required this.originalPrice, this.salePrice});

  static String _format(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M${AppStrings.productFilterCurrencySuffix}';
    }
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K${AppStrings.productFilterCurrencySuffix}';
    }
    return '${price.toStringAsFixed(0)}${AppStrings.productFilterCurrencySuffix}';
  }

  @override
  Widget build(BuildContext context) {
    if (salePrice != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _format(originalPrice),
            style: TextStyle(
              fontSize: AppSizes.fontSm,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            _format(salePrice!),
            style: TextStyle(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }
    return Text(
      _format(originalPrice),
      style: TextStyle(
        fontSize: AppSizes.fontMd,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;
  final String? tooltip;

  const _CardAction({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) => IconButton(
        icon: Icon(icon, color: color, size: size),
        onPressed: onTap,
        padding: const EdgeInsets.all(AppSizes.paddingXs),
        constraints: BoxConstraints(),
        tooltip: tooltip,
      );
}
