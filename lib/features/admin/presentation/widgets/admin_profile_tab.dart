import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/profile/presentation/widgets/profile_menu_row.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _AdminBioCard(user: user),
            const SizedBox(height: 28),
            _SectionLabel(AppStrings.adminShopSectionLabel),
            const SizedBox(height: 10),
            ProfileMenuRow(
              icon: Icons.store_mall_directory_outlined,
              label: AppStrings.shopInfoMenuLabel,
              onTap: () => context.pushNamed(AppRoutes.shopInfo),
            ),
            const SizedBox(height: 10),
            ProfileMenuRow(
              icon: Icons.settings_outlined,
              label: AppStrings.adminShopConfigMenuLabel,
              onTap: () => context.pushNamed(AppRoutes.adminShopConfig),
            ),
            const SizedBox(height: 28),
            _SectionLabel(AppStrings.profileAccountSection),
            const SizedBox(height: 10),
            _LogoutRow(),
          ],
        ),
      ),
    );
  }
}

class _AdminBioCard extends StatelessWidget {
  final dynamic user;

  const _AdminBioCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFF8FAFC).withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Row(
            children: [
              _AdminAvatar(url: user?.avatarUrl),
              const SizedBox(width: 16),
              Expanded(child: _buildBioText()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBioText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          user?.name ?? 'Admin Sport Pro',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'admin@sportpro.com',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
          ),
          child: Text(
            'QUẢN TRỊ VIÊN',
            style: GoogleFonts.spaceMono(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: AppColors.accent,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class _AdminAvatar extends StatelessWidget {
  final String? url;

  const _AdminAvatar({this.url});

  @override
  Widget build(BuildContext context) {
    final hasUrl = url != null && url!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 2.0,
        ),
      ),
      child: Stack(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3F3F8),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasUrl
                ? Image.network(
                    url!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _AvatarFallback(),
                  )
                : const _AvatarFallback(),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.person_rounded,
        size: 32, color: AppColors.textSecondary);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _LogoutRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return ProfileMenuRow(
          icon: Icons.logout_rounded,
          label: AppStrings.profileLogout,
          iconColor: AppColors.error,
          labelColor: AppColors.error,
          enabled: state is! AuthLoading,
          onTap: () =>
              context.read<AuthBloc>().add(const AuthLogoutRequested()),
        );
      },
    );
  }
}
