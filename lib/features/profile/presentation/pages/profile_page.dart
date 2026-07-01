import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/storage/app_settings_storage.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/app/widgets/glass_app_bar.dart';
import 'package:flutter_ecommerce/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:flutter_ecommerce/core/widgets/glass_bottom_bar.dart';
import 'package:flutter_ecommerce/app/router/navigation_history.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/app/theme/theme_cubit.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    NavigationHistory.pushTab(AppRoutes.profile);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  SizedBox(height: 28),
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
        final name = profile?.fullName ??
            (loading
                ? AppStrings.profileLoadingName
                : AppStrings.profileDefaultName);
        final email = profile?.email ??
            (state is ProfileError ? AppStrings.profileLoadError : '');

        final cardColor = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;

        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Theme.of(context).dividerColor),
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
                    cardColor,
                    cardColor.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  _BioAvatar(url: profile?.avatar, size: 64),
                  SizedBox(width: 16),
                  Expanded(child: _buildBioText(context, name, email, profile?.tier)),
                  _buildEditButton(context),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBioText(BuildContext context, String name, String email, String? tier) {
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
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 4),
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
          SizedBox(height: 8),
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
        AppStrings.profileTier(tier),
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
          color: Theme.of(context).colorScheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(Icons.edit_outlined,
            size: 16, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  // ── Menu ─────────────────────────────────────────────────────────────────────
  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildEyebrowHeader(AppStrings.profileAccountSection),
        SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.person_outline_rounded,
          label: AppStrings.profilePersonalInfo,
          onTap: () => context.pushNamed(AppRoutes.editProfile),
        ),
        SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.receipt_long_outlined,
          label: AppStrings.profileMyOrders,
          onTap: () => context.goNamed(AppRoutes.orderList),
        ),
        SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.location_on_outlined,
          label: AppStrings.profileShippingAddresses,
          onTap: () => context.goNamed(AppRoutes.orderList),
        ),
        SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.payment_outlined,
          label: AppStrings.profilePaymentMethods,
          onTap: () => context.goNamed(AppRoutes.orderList),
        ),
        SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.storefront_outlined,
          label: AppStrings.shopInfoMenuLabel,
          onTap: () => context.pushNamed(AppRoutes.shopInfo),
        ),
        SizedBox(height: 10),
        _buildLogoutRow(context),
        SizedBox(height: 24),
        _buildEyebrowHeader(AppStrings.profileSettingsSection),
        SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.notifications_none_rounded,
          label: AppStrings.profileAppNotifications,
          onTap: () => context.pushNamed(AppRoutes.notificationList),
        ),
        SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.chat_bubble_outline_rounded,
          label: AppStrings.profileInbox,
          onTap: () => context.pushNamed(AppRoutes.chatList),
        ),
        SizedBox(height: 10),
        ProfileMenuRow(
          icon: Icons.settings_outlined,
          label: AppStrings.profileSystemSettings,
          onTap: () => _showSystemSettingsSheet(context),
        ),
      ],
    );
  }

  void _showSystemSettingsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _SystemSettingsSheet(
        settingsStorage: AppSettingsStorage(sl<LocalStorage>()),
      ),
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
          label: AppStrings.profileLogout,
          iconColor: AppColors.error,
          labelColor: AppColors.error,
          enabled: !isLoading,
          onTap: () => _confirmLogout(context),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: AppStrings.profileLogout,
      message: AppStrings.profileLogoutConfirm,
      cancelLabel: AppStrings.cancel,
      confirmLabel: AppStrings.profileLogout,
    );

    if (confirmed && context.mounted) {
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
    return Icon(Icons.person_rounded,
        size: 32, color: AppColors.textSecondary);
  }
}

class _SystemSettingsSheet extends StatefulWidget {
  final AppSettingsStorage settingsStorage;

  const _SystemSettingsSheet({required this.settingsStorage});

  @override
  State<_SystemSettingsSheet> createState() => _SystemSettingsSheetState();
}

class _SystemSettingsSheetState extends State<_SystemSettingsSheet> {
  late bool _notificationSoundEnabled;

  @override
  void initState() {
    super.initState();
    _notificationSoundEnabled =
        widget.settingsStorage.isNotificationSoundEnabled;
  }

  Future<void> _setNotificationSoundEnabled(bool value) async {
    setState(() => _notificationSoundEnabled = value);
    await widget.settingsStorage.setNotificationSoundEnabled(value: value);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.systemSettingsTitle,
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                Icons.volume_up_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              title: Text(
                AppStrings.notificationSoundTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                AppStrings.notificationSoundSubtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.35),
              value: _notificationSoundEnabled,
              onChanged: _setNotificationSoundEnabled,
            ),
            const Divider(height: 24, color: Color(0xFFE2E8F0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.dark_mode_outlined,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    SizedBox(width: 14),
                    Text(
                      'Giao diện',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, currentMode) {
                    return DropdownButton<ThemeMode>(
                      value: currentMode,
                      underline: SizedBox(),
                      icon: Icon(Icons.keyboard_arrow_down_rounded),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Theo hệ thống'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Sáng'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Tối'),
                        ),
                      ],
                      onChanged: (mode) {
                        if (mode != null) {
                          context.read<ThemeCubit>().updateThemeMode(mode);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
    final theme = Theme.of(context);
    final iconColor = widget.iconColor ?? theme.colorScheme.onSurface;
    final labelColor = widget.labelColor ?? theme.colorScheme.onSurface;
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
              color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor),
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
                SizedBox(width: 14),
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
