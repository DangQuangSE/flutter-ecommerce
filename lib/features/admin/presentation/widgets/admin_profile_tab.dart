import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/widgets/settings/system_settings_sheet.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_state.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShopCubit>(
      create: (_) => sl<ShopCubit>()..loadShop(),
      child: const _AdminProfileBody(),
    );
  }
}

class _AdminProfileBody extends StatelessWidget {
  const _AdminProfileBody();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<ShopCubit, ShopState>(
              builder: (context, state) {
                final shop = state is ShopLoaded ? state.shop : null;
                final logoUrl = shop?.logoUrl;
                final shopName = shop?.name;

                return Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            backgroundImage: logoUrl != null
                                ? NetworkImage(logoUrl)
                                : null,
                            child: logoUrl == null
                                ? Icon(Icons.store_rounded,
                                    size: 48, color: AppColors.primary)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle),
                              child: Icon(Icons.verified_user_rounded,
                                  size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        shopName ?? user?.name ?? AppStrings.adminProfileFallbackName,
                        style: GoogleFonts.lexend(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary),
                      ),
                    ),
                    Center(
                      child: Text(
                        user?.email ?? 'admin@sportpro.com',
                        style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary),
                      ),
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppStrings.adminRoleLabel,
                          style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.accent,
                              letterSpacing: 0.5),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 48),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.store_mall_directory_rounded,
                        color: AppColors.primary),
                    title: Text(AppStrings.adminShopViewLabel,
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing:
                        Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => context.goNamed(AppRoutes.productList),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.settings_outlined,
                        color: AppColors.primary),
                    title: Text(AppStrings.adminShopConfigMenuLabel,
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing:
                        Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => context.pushNamed(AppRoutes.adminShopConfig),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.settings_outlined,
                        color: AppColors.primary),
                    title: Text(AppStrings.profileSystemSettings,
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing:
                        Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => SystemSettingsSheet.show(context),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.logout_rounded,
                        color: AppColors.error),
                    title: Text(AppStrings.adminLogoutLabel,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error)),
                    trailing: Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.error),
                    onTap: () => context
                        .read<AuthBloc>()
                        .add(const AuthLogoutRequested()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
