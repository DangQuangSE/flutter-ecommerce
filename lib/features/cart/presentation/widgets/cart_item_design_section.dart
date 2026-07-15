import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/cart/domain/entities/cart_item_entity.dart';
import 'package:flutter_ecommerce/features/cart/presentation/widgets/custom_design_spec_card.dart';

/// Bottom design panel shown when a cart item has a custom print design.
///
/// Displays a divider, design thumbnail, spec card, and edit/remove actions.
class CartItemDesignSection extends StatelessWidget {
  final CartItemEntity item;
  final bool isDark;
  final VoidCallback? onEditDesign;
  final VoidCallback onRemoveDesign;

  const CartItemDesignSection({
    super.key,
    required this.item,
    required this.isDark,
    required this.onEditDesign,
    required this.onRemoveDesign,
  });

  @override
  Widget build(BuildContext context) {
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
              _DesignHeader(onEditDesign: onEditDesign, onRemoveDesign: onRemoveDesign),
              const SizedBox(height: 10),
              _DesignDetail(item: item, isDark: isDark),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesignHeader extends StatelessWidget {
  final VoidCallback? onEditDesign;
  final VoidCallback onRemoveDesign;

  const _DesignHeader({required this.onEditDesign, required this.onRemoveDesign});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.build_outlined, size: 12, color: Color(0xFF0058BC)),
              const SizedBox(width: 6),
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
          style: GoogleFonts.inter(fontSize: 9, color: AppColors.textSecondary),
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
}

class _DesignDetail extends StatelessWidget {
  final CartItemEntity item;
  final bool isDark;

  const _DesignDetail({required this.item, required this.isDark});

  @override
  Widget build(BuildContext context) {
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
