import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// Bottom bar of the admin location picker: shows the picked address (or a
/// hint) and the "Lưu vị trí" button.
class AdminLocationSaveBar extends StatelessWidget {
  final String address;
  final bool canSave;
  final bool saving;
  final VoidCallback onSave;

  const AdminLocationSaveBar({
    super.key,
    required this.address,
    required this.canSave,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AddressLine(address: address, canSave: canSave),
          const SizedBox(height: AppSizes.paddingMd),
          _SaveButton(canSave: canSave, saving: saving, onSave: onSave),
        ],
      ),
    );
  }
}

class _AddressLine extends StatelessWidget {
  final String address;
  final bool canSave;

  const _AddressLine({required this.address, required this.canSave});

  @override
  Widget build(BuildContext context) {
    final showAddress = canSave && address.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          canSave ? Icons.place_rounded : Icons.info_outline_rounded,
          color: AppColors.primary,
          size: AppSizes.iconMd,
        ),
        const SizedBox(width: AppSizes.paddingSm),
        Expanded(
          child: Text(
            showAddress ? address : AppStrings.adminLocationNoSelection,
            style: GoogleFonts.inter(
              fontSize: AppSizes.fontLg,
              color: canSave ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool canSave;
  final bool saving;
  final VoidCallback onSave;

  const _SaveButton({
    required this.canSave,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: (!canSave || saving) ? null : onSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
        ),
        icon: saving
            ? const SizedBox(
                width: AppSizes.iconSm,
                height: AppSizes.iconSm,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                ),
              )
            : const Icon(Icons.save_rounded, size: AppSizes.iconMd),
        label: Text(
          saving
              ? AppStrings.adminLocationSaving
              : AppStrings.adminLocationSave,
          style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
