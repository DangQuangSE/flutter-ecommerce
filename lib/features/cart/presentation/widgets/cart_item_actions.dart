import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

/// Thumbnail image for a cart item (80×90 product image box).
class CartItemThumbnail extends StatelessWidget {
  final String? imageUrl;
  final bool isDark;

  const CartItemThumbnail({
    super.key,
    required this.imageUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
          imageUrl ?? '',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

/// Quantity stepper control for a cart item.
class CartItemQuantityControl extends StatelessWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CartItemQuantityControl({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onDecrement,
            child: SizedBox(
                width: 28, height: 28, child: Icon(Icons.remove, size: 12)),
          ),
          Text(
            '$quantity',
            style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface),
          ),
          GestureDetector(
            onTap: onIncrement,
            child: SizedBox(
                width: 28, height: 28, child: Icon(Icons.add, size: 12)),
          ),
        ],
      ),
    );
  }
}

/// Blue "IN TÙY CHỌN: +price" badge displayed on cart items with custom print.
class CartItemCustomBadge extends StatelessWidget {
  final double displayPrintingPrice;

  const CartItemCustomBadge({
    super.key,
    required this.displayPrintingPrice,
  });

  @override
  Widget build(BuildContext context) {
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
          const Icon(Icons.build_outlined, size: 10, color: Color(0xFF0058BC)),
          const SizedBox(width: 4),
          Text(
            'IN TÙY CHỌN: +${_formatPrice(displayPrintingPrice)}',
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

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    if (price == intPrice) {
      return '${_groupDigits(intPrice)}đ';
    }
    return '${price.toStringAsFixed(0)}đ';
  }

  String _groupDigits(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

/// "CUSTOM" pill button to customize a cart item.
class CartItemCustomizeButton extends StatelessWidget {
  final VoidCallback? onCustomize;

  const CartItemCustomizeButton({super.key, required this.onCustomize});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCustomize,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ??
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.brush_rounded, size: 12, color: AppColors.primary),
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
}

/// "XÓA" delete icon+text button for a cart item.
class CartItemDeleteButton extends StatelessWidget {
  final VoidCallback onRemove;

  const CartItemDeleteButton({super.key, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: Row(
        children: [
          Icon(Icons.delete_outline_rounded,
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
}
