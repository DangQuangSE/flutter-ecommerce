import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class GlassBottomBar extends StatelessWidget {
  final String currentTab;

  const GlassBottomBar({
    super.key,
    required this.currentTab,
  });

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    // Estimate notch height from status bar padding which remains consistent across all screens
    final double bottomPadding = statusBarHeight > 24 ? 24.0 : 12.0;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          // Flat bottom layout stretching completely, incorporating unified notch safe padding
          padding: EdgeInsets.fromLTRB(12, 10, 12, bottomPadding),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                width: 1.0,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                iconActive: Icons.home_rounded,
                iconInactive: Icons.home_outlined,
                label: 'Home',
                isActive: currentTab == 'home',
                onTap: () {
                  if (currentTab != 'home') {
                    context.goNamed(AppRoutes.home);
                  }
                },
              ),
              _buildNavItem(
                context,
                iconActive: Icons.directions_run_rounded,
                iconInactive: Icons.directions_run_rounded,
                label: 'Shop',
                isActive: currentTab == 'shop',
                onTap: () {
                  if (currentTab != 'shop') {
                    context.goNamed(AppRoutes.productList);
                  }
                },
              ),
              _buildNavItem(
                context,
                iconActive: Icons.receipt_long_rounded,
                iconInactive: Icons.receipt_long_outlined,
                label: 'Orders',
                isActive: currentTab == 'orders',
                onTap: () {
                  if (currentTab != 'orders') {
                    context.goNamed(AppRoutes.orderList);
                  }
                },
              ),
              _buildNavItem(
                context,
                iconActive: Icons.person_rounded,
                iconInactive: Icons.person_outline_rounded,
                label: 'Profile',
                isActive: currentTab == 'profile',
                onTap: () {
                  if (currentTab != 'profile') {
                    context.goNamed(AppRoutes.profile);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData iconActive,
    required IconData iconInactive,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const activeColor = AppColors.accent;
    final inactiveColor = AppColors.textSecondary.withValues(alpha: 0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? iconActive : iconInactive,
              color: isActive ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 9,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
