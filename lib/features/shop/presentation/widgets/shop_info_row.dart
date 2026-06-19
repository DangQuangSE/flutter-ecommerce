import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

/// A single labelled row (icon + text) for shop contact/meta information.
class ShopInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const ShopInfoRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconMd, color: AppColors.primary),
          const SizedBox(width: AppSizes.paddingSm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppSizes.fontLg,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
