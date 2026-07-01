import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/app/widgets/glass_app_bar.dart';
import 'package:flutter_ecommerce/core/widgets/glass_bottom_bar.dart';
import 'package:flutter_ecommerce/app/router/navigation_history.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    NavigationHistory.pushTab(AppRoutes.profile);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) return;
          if (context.canPop()) {
            context.pop();
          } else {
            final prevTab = NavigationHistory.popTab();
            if (prevTab != null) {
              context.goNamed(prevTab);
            }
          }
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, statusBarHeight + 92, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBioPanel(context),
                  const SizedBox(height: 28),
                  _buildMenuSection(context),
                ],
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child:
                  GlassAppBar(showBackButton: false, customTitle: 'Sport Pro'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GlassBottomBar(currentTab: 'profile'),
    );
  }

  // ── Bio panel (live profile data) ───────────────────────────────────────────
  Widget _buildBioPanel(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final profile = state is ProfileLoaded ? state.profile : null;
        final loading = state is ProfileLoading || state is ProfileInitial;
        final name =
            profile?.fullName ?? (loading ? 'Đang tải…' : 'Người dùng');
        final email = profile?.email ??
            (state is ProfileError ? 'Không tải được hồ sơ' : '');

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
                    const Color(0xFFFFFFFF),
                    const Color(0xFFF8FAFC).withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  _BioAvatar(url: profile?.avatar, size: 64),
                  const SizedBox(width: 16),
                  Expanded(child: _buildBioText(name, email, profile?.tier)),
                  _buildEditButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBioText(String name, String email, String? tier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
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
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        if (tier != null && tier.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTierBadge(tier),
        ],
      ],
    );
  }

  Widget _buildTierBadge(String tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Text(
        'HẠNG ${tier.toUpperCase()}',
        style: GoogleFonts.spaceMono(
          fontSize: 8,
          fontWeight: FontWeight.w900,
          color: AppColors.accent,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(AppRoutes.editProfile),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Icon(Icons.edit_outlined,
            size: 16, color: AppColors.textPrimary),
      ),
    );
  }

  // ── Menu ─────────────────────────────────────────────────────────────────────
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEyebrowHeader('TÀI KHOẢN VÀ BẢO MẬT'),
        const SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.person_outline_rounded,
          label: 'Thông tin cá nhân',
          onTap: () => context.pushNamed(AppRoutes.editProfile),
        ),
        const SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.receipt_long_outlined,
          label: 'Đơn hàng của tôi',
          onTap: () => context.goNamed(AppRoutes.orderList),
        ),
        const SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.location_on_outlined,
          label: 'Địa chỉ giao hàng',
          onTap: () => context.goNamed(AppRoutes.orderList),
        ),
        const SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.payment_outlined,
          label: 'Phương thức thanh toán',
          onTap: () => context.goNamed(AppRoutes.orderList),
        ),
        const SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.storefront_outlined,
          label: AppStrings.shopInfoMenuLabel,
          onTap: () => context.pushNamed(AppRoutes.shopInfo),
        ),
        const SizedBox(height: 10),
        _buildLogoutRow(context),
        const SizedBox(height: 24),
        _buildEyebrowHeader('THIẾT LẬP VÀ TIN NHẮN'),
        const SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.notifications_none_rounded,
          label: 'Thông báo ứng dụng',
          onTap: () => context.pushNamed(AppRoutes.notificationList),
        ),
        const SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.chat_bubble_outline_rounded,
          label: 'Hộp thư tin nhắn',
          onTap: () => context.pushNamed(AppRoutes.chatList),
        ),
        const SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.settings_outlined,
          label: 'Cài đặt hệ thống',
          onTap: () => context.goNamed(AppRoutes.home),
        ),
      ],
    );
  }

  Widget _buildEyebrowHeader(String label) {
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

  Widget _buildLogoutRow(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return ProfileMenuRow(
          icon: Icons.logout_rounded,
          label: 'Đăng xuất',
          iconColor: AppColors.error,
          labelColor: AppColors.error,
          enabled: !isLoading,
          onTap: () => _confirmLogout(context),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Đăng xuất',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Bạn có chắc muốn đăng xuất?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Hủy',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Đăng xuất',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }
}

/// Circular avatar that shows a network image, falling back to a person icon
/// when the URL is missing or fails to load.
class _BioAvatar extends StatelessWidget {
  final String? url;
  final double size;

  const _BioAvatar({required this.url, required this.size});

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
      child: Container(
        width: size,
        height: size,
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

// Stateful interactive menu row with tactile spring scale micro-physics feedback
class ProfileMenuRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final bool enabled;

  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
    this.enabled = true,
  });

  @override
  State<ProfileMenuRow> createState() => _ProfileMenuRowState();
}

class _ProfileMenuRowState extends State<ProfileMenuRow> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.iconColor ?? AppColors.textPrimary;
    final labelColor = widget.labelColor ?? AppColors.textPrimary;
    final opacity = widget.enabled ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => _scale = 0.97) : null,
        onTapUp: widget.enabled
            ? (_) {
                setState(() => _scale = 1.0);
                widget.onTap();
              }
            : null,
        onTapCancel: widget.enabled ? () => setState(() => _scale = 1.0) : null,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 150),
          curve: Curves.fastLinearToSlowEaseIn,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.01),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(widget.icon, size: 20, color: iconColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: widget.iconColor ?? AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
