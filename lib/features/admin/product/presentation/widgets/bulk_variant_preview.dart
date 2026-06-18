part of 'bulk_variant_sheet.dart';

// ── Preview section ───────────────────────────────────────────────────────────

class _PreviewSection extends StatelessWidget {
  final List<CreateVariantParams> preview;
  final List<ProductColorEntity> colors;
  final ValueChanged<int> onRemove;
  final ValueChanged<int> onEdit;

  const _PreviewSection({
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
          const SizedBox(height: AppSizes.paddingSm),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: preview.length,
            separatorBuilder: (_, __) =>
                const SizedBox(height: AppSizes.paddingXs + 2),
            itemBuilder: (_, i) {
              final item = preview[i];
              final color =
                  colors.where((c) => c.id == item.colorId).firstOrNull ??
                      const ProductColorEntity(name: '?', hexCode: '#999999');
              return _PreviewItemCard(
                item: item,
                color: color,
                onRemove: () => onRemove(i),
                onEdit: () => onEdit(i),
              );
            },
          ),
        ],
      );
}

class _PreviewHeader extends StatelessWidget {
  final int count;
  const _PreviewHeader({required this.count});

  @override
  Widget build(BuildContext context) => Row(children: [
        _sectionLabel('XEM TRƯỚC'),
        const SizedBox(width: AppSizes.paddingSm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
          ),
          child: Text(
            '$count biến thể',
            style: const TextStyle(
                fontSize: AppSizes.fontSm,
                color: AppColors.primary,
                fontWeight: FontWeight.w600),
          ),
        ),
      ]);
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        child: Row(children: [
          _ColorDot(hexCode: color.hexCode),
          _SizeBadge(size: item.size),
          const SizedBox(width: AppSizes.paddingSm),
          Expanded(child: _VariantInfo(colorName: color.name, sku: item.sku)),
          _PriceDisplay(originalPrice: item.originalPrice),
          _CardAction(
              icon: Icons.edit_outlined,
              color: AppColors.primary,
              size: AppSizes.iconSm + 2,
              tooltip: 'Sửa',
              onTap: onEdit),
          _CardAction(
              icon: Icons.remove_circle_outline_rounded,
              color: AppColors.error,
              size: AppSizes.iconMd,
              onTap: onRemove),
        ]),
      );
}

// ── Card sub-widgets ──────────────────────────────────────────────────────────

class _ColorDot extends StatelessWidget {
  final String hexCode;
  const _ColorDot({required this.hexCode});

  @override
  Widget build(BuildContext context) => Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.only(right: AppSizes.paddingSm),
        decoration: BoxDecoration(
          color: _hexColor(hexCode),
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Text(size,
            style: const TextStyle(
                fontSize: AppSizes.fontSm, fontWeight: FontWeight.w600)),
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
          Text(colorName,
              style: const TextStyle(
                  fontSize: AppSizes.fontLg, fontWeight: FontWeight.w500)),
          Text(sku,
              style: const TextStyle(
                  fontSize: AppSizes.fontSm, color: AppColors.textSecondary)),
        ],
      );
}

class _PriceDisplay extends StatelessWidget {
  final double originalPrice;
  const _PriceDisplay({required this.originalPrice});

  static String _fmt(double price) {
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M₫';
    if (price >= 1000) return '${(price / 1000).toStringAsFixed(0)}K₫';
    return '${price.toStringAsFixed(0)}₫';
  }

  @override
  Widget build(BuildContext context) => Text(_fmt(originalPrice),
      style: const TextStyle(
          fontSize: AppSizes.fontMd,
          fontWeight: FontWeight.w500,
          color: AppColors.primary));
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
        constraints: const BoxConstraints(),
        tooltip: tooltip,
      );
}

// ── Bottom actions ────────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback? onConfirm;
  final int count;

  const _BottomActions({
    required this.onCancel,
    required this.onConfirm,
    required this.count,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(AppSizes.paddingMd,
            AppSizes.paddingSm, AppSizes.paddingMd, AppSizes.paddingMd),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: Row(children: [
          Expanded(
            child:
                OutlinedButton(onPressed: onCancel, child: const Text('Hủy')),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                  count > 0 ? 'Xác nhận & Lưu ($count)' : 'Xác nhận & Lưu'),
            ),
          ),
        ]),
      );
}
