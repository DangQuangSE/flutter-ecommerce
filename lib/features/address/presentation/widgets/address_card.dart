import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';

class AddressCard extends StatelessWidget {
  final AddressEntity address;
  final VoidCallback? onSetDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AddressCard({
    super.key,
    required this.address,
    this.onSetDefault,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMd),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(),
            const SizedBox(height: AppSizes.paddingSm),
            _buildInfoRow(Icons.person_outline, address.fullName),
            _buildInfoRow(Icons.phone_outlined, address.phoneNumber),
            _buildInfoRow(Icons.location_on_outlined, address.formattedAddress),
            if (address.label != null && address.label!.isNotEmpty)
              _buildLabelChip(),
            const Divider(height: AppSizes.paddingXl),
            _buildActionRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            address.fullName,
            style: const TextStyle(
              fontSize: AppSizes.fontXxl,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (address.isDefault) _buildDefaultBadge(),
      ],
    );
  }

  Widget _buildDefaultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: const Text(
        AppStrings.addressDefaultLabel,
        style: TextStyle(
          fontSize: AppSizes.fontSm,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.textSecondary),
          const SizedBox(width: AppSizes.paddingSm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: AppSizes.fontLg,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelChip() {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.paddingSm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Text(
        address.label!,
        style: const TextStyle(
          fontSize: AppSizes.fontSm,
          color: AppColors.accent,
        ),
      ),
    );
  }

  Widget _buildActionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!address.isDefault)
          _ActionButton(
            label: AppStrings.addressSetDefault,
            onTap: onSetDefault,
          ),
        const SizedBox(width: AppSizes.paddingSm),
        _ActionButton(label: AppStrings.addressEdit, onTap: onEdit),
        const SizedBox(width: AppSizes.paddingSm),
        _ActionButton(label: AppStrings.addressDelete, onTap: onDelete),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingSm,
          vertical: 4,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppSizes.fontMd,
            color: onTap != null ? AppColors.primary : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}
