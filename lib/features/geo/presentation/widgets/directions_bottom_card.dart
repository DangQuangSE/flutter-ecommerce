import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/route_preview.dart';

/// Grab/Be-style bottom card showing the route distance + ETA with a "Bắt đầu"
/// button that hands off to the Google Maps app.
class DirectionsBottomCard extends StatelessWidget {
  final RoutePreview route;
  final VoidCallback onStart;
  final VoidCallback onClose;

  const DirectionsBottomCard({
    super.key,
    required this.route,
    required this.onStart,
    required this.onClose,
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
      child: Row(
        children: [
          _RouteSummary(route: route),
          const Spacer(),
          _CloseButton(onClose: onClose),
          const SizedBox(width: AppSizes.paddingSm),
          _StartButton(onStart: onStart),
        ],
      ),
    );
  }
}

class _RouteSummary extends StatelessWidget {
  final RoutePreview route;

  const _RouteSummary({required this.route});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.directions_car_filled_rounded,
          color: AppColors.primary,
          size: AppSizes.iconLg,
        ),
        const SizedBox(width: AppSizes.paddingSm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              route.durationText,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              route.distanceText,
              style: GoogleFonts.inter(
                fontSize: AppSizes.fontMd,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onClose;

  const _CloseButton({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onClose,
      tooltip: AppStrings.shopDirectionsCloseLabel,
      icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onStart;

  const _StartButton({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onStart,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
      ),
      icon: const Icon(Icons.navigation_rounded, size: AppSizes.iconSm),
      label: Text(
        AppStrings.shopStartNavigation,
        style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
      ),
    );
  }
}
