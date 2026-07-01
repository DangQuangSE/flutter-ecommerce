import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/utils/price_formatter.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/custom_design_spec_card.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final bool isSelected;
  final ValueChanged<bool> onToggleSelected;
  final VoidCallback onIncrementQuantity;
  final VoidCallback onDecrementQuantity;
  final VoidCallback onRemove;
  final VoidCallback? onCustomize;
  final VoidCallback? onEditDesign;
  final VoidCallback onRemoveDesign;

  const CartItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onToggleSelected,
    required this.onIncrementQuantity,
    required this.onDecrementQuantity,
    required this.onRemove,
    this.onCustomize,
    this.onEditDesign,
    required this.onRemoveDesign,
  });

  @override
  Widget build(BuildContext context) {
    final category =
        item.isCustomizable ? 'TRANG BỊ HIỆU NĂNG' : 'THỜI TRANG THỂ THAO';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCheckbox(),
                _buildThumbnail(context, isDark),
                SizedBox(width: 12),
                Expanded(child: _buildDetails(context, category, isDark)),
              ],
            ),
          ),
          if (item.customDesignId != null) _buildDesignSection(context, isDark),
        ],
      ),
    );
  }

  Widget _buildCheckbox() {
    return Padding(
      padding: const EdgeInsets.only(top: 35, right: 8),
      child: SizedBox(
        width: 20,
        height: 20,
        child: Checkbox(
          value: isSelected,
          activeColor: AppColors.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          onChanged: (val) {
            if (val != null) onToggleSelected(val);
          },
        ),
      ),
    );
  }

  Widget _buildThumbnail(BuildContext context, bool isDark) {
    return Container(
      width: 80,
      height: 90,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF3F3F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.imageUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, String category, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(context, category),
        SizedBox(height: 6),
        Text(
          'Màu sắc: ${item.color ?? "N/A"}    Kích cỡ: ${item.size ?? "N/A"}',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        if (item.customDesignId != null) ...[
          SizedBox(height: 6),
          _buildCustomBadge(),
        ],
        SizedBox(height: 10),
        _buildBottomRow(context, category),
      ],
    );
  }

  Widget _buildHeaderRow(BuildContext context, String category) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0058BC),
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        Text(
          formatPrice(item.price + item.printingPrice),
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.onSurface,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFADCCF6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.build_outlined,
              size: 10, color: Color(0xFF0058BC)),
          SizedBox(width: 4),
          Text(
            'IN TÙY CHỌN: +${formatPrice(item.printingPrice)}',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0058BC),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context, String category) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuantityControl(context),
        SizedBox(width: 8),
        if (category == 'TRANG BỊ HIỆU NĂNG' && item.customDesignId == null)
          _buildCustomizeButton(context),
        const Spacer(),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildQuantityControl(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrementQuantity,
            child: SizedBox(
                width: 28, height: 28, child: Icon(Icons.remove, size: 12)),
          ),
          Text(
            '${item.quantity}',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          GestureDetector(
            onTap: onIncrementQuantity,
            child: SizedBox(
                width: 28, height: 28, child: Icon(Icons.add, size: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizeButton(BuildContext context) {
    return GestureDetector(
      onTap: onCustomize,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.brush_rounded, size: 12, color: AppColors.primary),
            SizedBox(width: 4),
            Text(
              'CUSTOM',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return GestureDetector(
      onTap: onRemove,
      child: Row(
        children: [
          Icon(Icons.delete_outline_rounded,
              size: 14, color: AppColors.textSecondary),
          SizedBox(width: 4),
          Text(
            'XÓA',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignSection(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 1,
          color: Theme.of(context).dividerColor.withValues(alpha: 0.15),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDesignHeader(context),
              SizedBox(height: 10),
              _buildDesignDetail(context, isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesignHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.build_outlined,
                  size: 12, color: Color(0xFF0058BC)),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'CHI TIẾT THIẾT KẾ IN ẤN',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: onEditDesign,
          child: Text(
            'CHỈNH SỬA THIẾT KẾ',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0058BC),
            ),
          ),
        ),
        Text(
          '  |  ',
          style: GoogleFonts.inter(
              fontSize: 9, color: AppColors.textSecondary),
        ),
        GestureDetector(
          onTap: onRemoveDesign,
          child: Text(
            'XÓA THIẾT KẾ',
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesignDetail(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.designImageUrl ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 14, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: CustomDesignSpecCard(
              customDesignId: item.customDesignId!,
              fallbackPrintingPrice: item.printingPrice,
            ),
          ),
        ],
      ),
    );
  }
}
