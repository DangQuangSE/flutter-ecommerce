import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';

class BrandCard extends StatelessWidget {
  final BrandEntity brand;
  final ValueChanged<bool> onToggleStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BrandCard({
    super.key,
    required this.brand,
    required this.onToggleStatus,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _BrandAvatar(brand: brand),
                SizedBox(width: 16),
                Expanded(child: _BrandSummary(brand: brand)),
                Switch.adaptive(
                  value: brand.isActive,
                  activeThumbColor: AppColors.primary,
                  onChanged: onToggleStatus,
                ),
              ],
            ),
            if (brand.description.isNotEmpty) ...[
              SizedBox(height: 12),
              Text(
                brand.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            SizedBox(height: 12),
            const Divider(height: 1),
            SizedBox(height: 12),
            _BrandFooter(
              brand: brand,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandAvatar extends StatelessWidget {
  final BrandEntity brand;

  const _BrandAvatar({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: brand.logoUrl.isNotEmpty
            ? Image.network(
                brand.logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _FallbackBrandAvatar(name: brand.name),
              )
            : _FallbackBrandAvatar(name: brand.name),
      ),
    );
  }
}

class _FallbackBrandAvatar extends StatelessWidget {
  final String name;

  const _FallbackBrandAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'B';

    return Center(
      child: Text(
        initial,
        style: GoogleFonts.lexend(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _BrandSummary extends StatelessWidget {
  final BrandEntity brand;

  const _BrandSummary({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          brand.name,
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Icon(
              Icons.public_rounded,
              size: 12,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 4),
            Expanded(
              child: Text(
                brand.country.isNotEmpty
                    ? brand.country
                    : 'Chưa có thông tin quốc gia',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BrandFooter extends StatelessWidget {
  final BrandEntity brand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BrandFooter({
    required this.brand,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: brand.websiteUrl.isNotEmpty
              ? Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        brand.websiteUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: onEdit,
              icon: Icon(
                Icons.edit_outlined,
                color: Colors.blue,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 20,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
