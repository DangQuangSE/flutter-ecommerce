import 'dart:ui';
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
          height: 390,
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
              Positioned(
                top: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFFFB300),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'PRO-CARBON',
                            style: GoogleFonts.spaceMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SPECIFICATION',
                            style: GoogleFonts.spaceMono(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildSpecRow('ENERGY', '85%'),
                          const SizedBox(height: 4),
                          _buildSpecRow('WEIGHT', '180G'),
                          const SizedBox(height: 4),
                          _buildSpecRow('PLATE', '3D-CARBON'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const _HeroContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceMono(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
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
            Colors.black38,
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
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'BỨT PHÁ\n',
                  style: GoogleFonts.lexend(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppColors.white,
                    height: 1.1,
                  ),
                ),
                TextSpan(
                  text: 'GIỚI HẠN',
                  style: GoogleFonts.lexend(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppColors.accent,
                    height: 1.1,
                  ),
                ),
              ],
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

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.accent,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
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
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _PulsingDot(),
          const SizedBox(width: 8),
          Text(
            AppStrings.productHomeHeroEyebrow,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.white,
              letterSpacing: 1.5,
            ),
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
