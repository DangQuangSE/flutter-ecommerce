import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/widgets/settings/system_settings_sheet.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
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

    return BlocBuilder<ShopCubit, ShopState>(
      builder: (context, state) {
        final shop = state is ShopLoaded ? state.shop : null;

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AdminCoverHeader(shop: shop),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          shop?.name ?? user?.name ?? AppStrings.adminProfileFallbackName,
                          style: GoogleFonts.lexend(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(height: 4),
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
                      SizedBox(height: 24),
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                              color: Theme.of(context).dividerColor),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.store_mall_directory_rounded,
                                  color: AppColors.primary),
                              title: Text(AppStrings.adminShopViewLabel,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14),
                              onTap: () =>
                                  context.goNamed(AppRoutes.productList),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.settings_outlined,
                                  color: AppColors.primary),
                              title: Text(AppStrings.adminShopConfigMenuLabel,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14),
                              onTap: () => context
                                  .pushNamed(AppRoutes.adminShopConfig),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.settings_outlined,
                                  color: AppColors.primary),
                              title: Text(AppStrings.profileSystemSettings,
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600)),
                              trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14),
                              onTap: () =>
                                  SystemSettingsSheet.show(context),
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
                              trailing: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 14,
                                  color: AppColors.error),
                              onTap: () => context
                                  .read<AuthBloc>()
                                  .add(const AuthLogoutRequested()),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminCoverHeader extends StatelessWidget {
  final ShopEntity? shop;

  const _AdminCoverHeader({this.shop});

  @override
  Widget build(BuildContext context) {
    final coverHeight =
        MediaQuery.of(context).size.width * AppSizes.shopCoverRatio;
    return SizedBox(
      height: coverHeight + AppSizes.shopLogoSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _AdminCoverImage(coverUrl: shop?.coverUrl, height: coverHeight),
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 2 -
                AppSizes.shopLogoSize / 2,
            child: _AdminLogoAvatar(
              logoUrl: shop?.logoUrl,
              name: shop?.name ?? AppStrings.adminProfileFallbackName,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCoverImage extends StatelessWidget {
  final String? coverUrl;
  final double height;

  const _AdminCoverImage({this.coverUrl, required this.height});

  @override
  Widget build(BuildContext context) {
    if (coverUrl == null || coverUrl!.isEmpty) {
      return _placeholder();
    }
    return CachedNetworkImage(
      imageUrl: coverUrl!,
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
      errorWidget: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() {
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.15),
      child: const Icon(
        Icons.store_mall_directory_rounded,
        size: AppSizes.iconXl,
        color: AppColors.primary,
      ),
    );
  }
}

class _AdminLogoAvatar extends StatelessWidget {
  final String? logoUrl;
  final String name;

  const _AdminLogoAvatar({this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.shopLogoSize,
      height: AppSizes.shopLogoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: AppSizes.borderThick),
        color: Theme.of(context).cardTheme.color,
      ),
      clipBehavior: Clip.antiAlias,
      child: (logoUrl != null && logoUrl!.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _fallbackLogo(name),
            )
          : _fallbackLogo(name),
    );
  }

  Widget _fallbackLogo(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppSizes.fontDisplay,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
