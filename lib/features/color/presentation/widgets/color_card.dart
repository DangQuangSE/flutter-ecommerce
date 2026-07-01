import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class ColorCard extends StatelessWidget {
  final String name;
  final String hexCode;
  final bool? isActive;
  final ValueChanged<bool>? onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ColorCard({
    super.key,
    required this.name,
    required this.hexCode,
    this.isActive,
    this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  static Color _hexToColor(String hex) {
    try {
      String clean = hex.replaceAll('#', '').trim();
      if (clean.length == 3) clean = clean.split('').map((c) => '$c$c').join();
      if (clean.length == 6) clean = 'FF$clean';
      return Color(int.parse(clean, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewColor = _hexToColor(hexCode);
    final isDarkColor =
        ThemeData.estimateBrightnessForColor(previewColor) == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 4,
            child: _ColorPreviewBar(
              previewColor: previewColor,
              hexCode: hexCode,
              isDarkColor: isDarkColor,
              isActive: isActive,
            ),
          ),
          Expanded(
            flex: 5,
            child: _ColorCardActions(
              name: name,
              isActive: isActive,
              onToggleActive: onToggleActive,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorPreviewBar extends StatelessWidget {
  final Color previewColor;
  final String hexCode;
  final bool isDarkColor;
  final bool? isActive;

  const _ColorPreviewBar({
    required this.previewColor,
    required this.hexCode,
    required this.isDarkColor,
    this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: previewColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSizes.radiusXl),
          topRight: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              hexCode,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDarkColor ? AppColors.white : Colors.black87,
                letterSpacing: 0.5,
              ),
            ),
          ),
          if (isActive != null)
            Positioned(
              top: 4,
              right: 4,
              child: _StatusBadge(isActive: isActive!),
            ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withValues(alpha: 0.85)
            : Colors.red.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive
            ? AppStrings.adminColorStatusActive
            : AppStrings.adminColorStatusDisabled,
        style: GoogleFonts.inter(
          color: AppColors.white,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ColorCardActions extends StatelessWidget {
  final String name;
  final bool? isActive;
  final ValueChanged<bool>? onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ColorCardActions({
    required this.name,
    this.isActive,
    this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isActive != null && onToggleActive != null)
                SizedBox(
                  width: 36,
                  height: 20,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Switch.adaptive(
                      value: isActive!,
                      activeThumbColor: AppColors.primary,
                      onChanged: onToggleActive,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.edit_outlined,
                        color: AppColors.primary, size: 18),
                    onPressed: onEdit,
                  ),
                  SizedBox(width: 12),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.delete_outline_rounded,
                        color: AppColors.error, size: 18),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
