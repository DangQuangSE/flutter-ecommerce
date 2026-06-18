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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
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
                _buildThumbnail(),
                const SizedBox(width: 12),
                Expanded(child: _buildDetails(category)),
              ],
            ),
          ),
          if (item.customDesignId != null) _buildDesignSection(),
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

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          item.imageUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(String category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderRow(category),
        const SizedBox(height: 6),
        Text(
          'Màu sắc: ${item.color ?? "N/A"}    Kích cỡ: ${item.size ?? "N/A"}',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        if (item.customDesignId != null) ...[
          const SizedBox(height: 6),
          _buildCustomBadge(),
        ],
        const SizedBox(height: 10),
        _buildBottomRow(category),
      ],
    );
  }

  Widget _buildHeaderRow(String category) {
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
              const SizedBox(height: 4),
              Text(
                item.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatPrice(item.price + item.printingPrice),
          style: GoogleFonts.lexend(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
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
          const Icon(Icons.build_outlined,
              size: 10, color: Color(0xFF0058BC)),
          const SizedBox(width: 4),
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

  Widget _buildBottomRow(String category) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuantityControl(),
        const SizedBox(width: 8),
        if (category == 'TRANG BỊ HIỆU NĂNG' && item.customDesignId == null)
          _buildCustomizeButton(),
        const Spacer(),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildQuantityControl() {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC1C6D7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrementQuantity,
            child: const SizedBox(
                width: 28, height: 28, child: Icon(Icons.remove, size: 12)),
          ),
          Text(
            '${item.quantity}',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
          ),
          GestureDetector(
            onTap: onIncrementQuantity,
            child: const SizedBox(
                width: 28, height: 28, child: Icon(Icons.add, size: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizeButton() {
    return GestureDetector(
      onTap: onCustomize,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.brush_rounded, size: 12, color: AppColors.primary),
            const SizedBox(width: 4),
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
          const Icon(Icons.delete_outline_rounded,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
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

  Widget _buildDesignSection() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          height: 1,
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.15),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDesignHeader(),
              const SizedBox(height: 10),
              _buildDesignDetail(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesignHeader() {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.build_outlined,
                  size: 12, color: Color(0xFF0058BC)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'CHI TIẾT THIẾT KẾ IN ẤN',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
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

  Widget _buildDesignDetail() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFFC1C6D7).withValues(alpha: 0.2),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.designImageUrl ?? '',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 14, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
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
