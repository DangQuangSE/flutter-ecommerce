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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingLg,
        AppSizes.paddingXl,
        AppSizes.paddingLg,
        AppSizes.paddingMd,
      ),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? const Color(0xFF334155).withValues(alpha: 0.5)
                : AppColors.divider,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          height: 380,
          decoration: BoxDecoration(
            color: AppColors.black,
            borderRadius: BorderRadius.circular(22),
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
          Transform(
            transform: Matrix4.skewX(-0.10),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'BỨT PHÁ\n',
                    style: GoogleFonts.lexend(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'GIỚI HẠN',
                    style: GoogleFonts.lexend(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.accent,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.productHomeHeroSubtitle,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          _HeroCta(
            label: AppStrings.productHomeHeroCta,
            onPressed: () => context.goNamed(AppRoutes.productList),
          ),
        ],
      ),
    );
  }
}

class _HeroCta extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _HeroCta({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_HeroCta> createState() => _HeroCtaState();
}

class _HeroCtaState extends State<_HeroCta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = _controller;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onPressed();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
