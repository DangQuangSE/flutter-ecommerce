import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

/// A single labelled row (icon + text) for shop contact/meta information.
/// Passing [onTap] (e.g. "Chỉ đường") makes the row tappable and adds a
/// trailing chevron affordance; omit it for plain display-only rows
/// (address, phone, opening hours).
class ShopInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ShopInfoRow({
    super.key,
    required this.icon,
    required this.text,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSizes.iconMd, color: AppColors.primary),
        const SizedBox(width: AppSizes.paddingSm),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppSizes.fontLg,
              color: onTap == null ? AppColors.textPrimary : AppColors.primary,
            ),
          ),
        ),
        if (trailing != null) trailing!,
        if (onTap != null)
          const Icon(
            Icons.chevron_right_rounded,
            size: AppSizes.iconMd,
            color: AppColors.primary,
          ),
      ],
    );

    if (onTap == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXs),
        child: row,
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXs),
        child: row,
      ),
    );
  }
}
