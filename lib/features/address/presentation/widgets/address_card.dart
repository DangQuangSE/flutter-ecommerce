import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';

class AddressCard extends StatelessWidget {
  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.selectable = false,
    this.selected = false,
    this.onTap,
  });

  final AddressEntity address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;
  final bool selectable;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppSizes.cardPadding,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AddressCardHeader(
              address: address,
              selectable: selectable,
              selected: selected,
            ),
            AppSizes.spacingSm,
            _AddressCardBody(address: address),
            AppSizes.spacingMd,
            _AddressCardActions(
              address: address,
              onEdit: onEdit,
              onDelete: onDelete,
              onSetDefault: onSetDefault,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCardHeader extends StatelessWidget {
  const _AddressCardHeader({
    required this.address,
    required this.selectable,
    required this.selected,
  });

  final AddressEntity address;
  final bool selectable;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (selectable)
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: AppSizes.iconMd,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          ),
        if (selectable) AppSizes.spacingSm,
        Text(
          address.fullName,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        AppSizes.spacingSm,
        Text(
          address.phoneNumber,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontLg,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        if (address.label != null) _LabelChip(label: address.label!),
        if (address.isDefault) ...[
          if (address.label != null) const SizedBox(width: 6),
          _DefaultBadge(),
        ],
      ],
    );
  }
}

class _AddressCardBody extends StatelessWidget {
  const _AddressCardBody({required this.address});

  final AddressEntity address;

  @override
  Widget build(BuildContext context) {
    return Text(
      address.fullAddress,
      style: GoogleFonts.plusJakartaSans(
        fontSize: AppSizes.fontLg,
        color: AppColors.textSecondary,
        height: 1.5,
      ),
    );
  }
}

class _AddressCardActions extends StatelessWidget {
  const _AddressCardActions({
    required this.address,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final AddressEntity address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!address.isDefault)
          _TextActionButton(
            label: 'Đặt mặc định',
            onTap: onSetDefault,
          ),
        const Spacer(),
        _TextActionButton(label: 'Sửa', onTap: onEdit),
        const SizedBox(width: 12),
        _TextActionButton(
          label: 'Xóa',
          onTap: onDelete,
          color: AppColors.error,
        ),
      ],
    );
  }
}

class _TextActionButton extends StatelessWidget {
  const _TextActionButton({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: AppSizes.fontLg,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.primary,
        ),
      ),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        'Mặc định',
        style: GoogleFonts.plusJakartaSans(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: AppSizes.fontSm,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
