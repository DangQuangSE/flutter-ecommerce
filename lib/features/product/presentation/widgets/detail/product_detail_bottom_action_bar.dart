import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class ProductDetailBottomActionBar extends StatelessWidget {
  final bool isFavorited;
  final bool isInStock;
  final VoidCallback onToggleFavorite;
  final VoidCallback onAddToCart;

  const ProductDetailBottomActionBar({
    super.key,
    required this.isFavorited,
    required this.isInStock,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _FavoriteButton(
              isFavorited: isFavorited,
              onPressed: onToggleFavorite,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: isInStock ? onAddToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isInStock ? AppColors.accent : Colors.grey[400],
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isInStock
                          ? Icons.shopping_bag_outlined
                          : Icons.remove_shopping_cart_outlined,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isInStock ? AppStrings.addToCart : AppStrings.outOfStock,
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorited;
  final VoidCallback onPressed;

  const _FavoriteButton({
    required this.isFavorited,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFavorited ? Colors.red : const Color(0xFFC1C6D7),
            width: 1.5,
          ),
        ),
        child: Icon(
          isFavorited ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorited ? Colors.red : AppColors.textSecondary,
          size: 24,
        ),
      ),
    );
  }
}
