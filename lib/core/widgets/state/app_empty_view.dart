import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';

class AppEmptyView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyView({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding:
              const EdgeInsets.all(AppSizes.paddingXl + AppSizes.paddingSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: AppSizes.iconXl - AppSizes.paddingSm,
                  color: AppColors.textSecondary),
              const SizedBox(height: AppSizes.paddingMd),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: AppSizes.fontXl,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: AppSizes.paddingXs + 2),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: AppSizes.forgotPasswordFontSize,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSizes.paddingMd),
                FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      );
}
