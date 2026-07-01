import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class ProductHomeHeroSection extends StatelessWidget {
  static const _heroImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDfNUm_0FHTlwMSO97i6w_ybGmHoVLk34xXuVJ138ODeFyymicdmeoElKE4Dw81L669C3EY5e3nBvEaHO2ATTV4XRAbGpQa9oJk7YDslOWIh5l3Cet1fbGGmoW6374uazzBD6RKNWmaZ_9VmgeDnFssIy9zvvN1_YLcGOe8LXyWG63NcbpAyus8mOU5IT6-HZBiyV8msC80n3Zzr4JIoddV8XatdZ_RGD-GClcpI9keO_oHzq8zRr6z6giBAQ6BwerYe3LWlHOp31c';

  const ProductHomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingLg,
        AppSizes.paddingXl,
        AppSizes.paddingLg,
        AppSizes.paddingMd,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSizes.radiusSm),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.paddingXl),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.02),
              blurRadius: AppSizes.radiusXl,
              offset: const Offset(0, AppSizes.paddingSm),
            ),
          ],
        ),
        child: Container(
          height: 380,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(AppSizes.fontXxl),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(_heroImageUrl, fit: BoxFit.cover),
              const _HeroOverlay(),
              const _HeroContent(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroOverlay extends StatelessWidget {
  const _HeroOverlay();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black87,
            Colors.black26,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroEyebrow(),
          const SizedBox(height: AppSizes.radiusLg),
          Transform(
            transform: Matrix4.skewX(-0.12),
            child: Text(
              AppStrings.productHomeHeroTitle,
              style: GoogleFonts.lexend(
                fontSize: AppSizes.iconLg,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.radiusSm),
          Text(
            AppStrings.productHomeHeroSubtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          AppSizes.spacingLg,
          _HeroCta(
            label: AppStrings.productHomeHeroCta,
            onPressed: () => context.goNamed(AppRoutes.productList),
          ),
        ],
      ),
    );
  }
}

class _HeroEyebrow extends StatelessWidget {
  const _HeroEyebrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.radiusMd,
        vertical: AppSizes.paddingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.15)),
      ),
      child: Text(
        AppStrings.productHomeHeroEyebrow,
        style: GoogleFonts.plusJakartaSans(
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w800,
          color: AppColors.white,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _HeroCta extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _HeroCta({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingLg,
          AppSizes.radiusSm,
          AppSizes.radiusSm,
          AppSizes.radiusSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        minimumSize: Size.zero,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: AppSizes.fontMd,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: AppSizes.fontLg),
          const _HeroCtaIcon(),
        ],
      ),
    );
  }
}

class _HeroCtaIcon extends StatelessWidget {
  const _HeroCtaIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Icon(
          Icons.arrow_forward_rounded,
          size: AppSizes.fontXl,
          color: AppColors.accent,
        ),
      ),
    );
  }
}
