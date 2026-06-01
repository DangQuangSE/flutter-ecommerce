import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/widgets/glass_app_bar.dart';
import 'package:flutter_ecommerce/core/widgets/glass_bottom_bar.dart';
import 'package:flutter_ecommerce/app/router/navigation_history.dart';

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
        onPopInvoked: (bool didPop) {
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
            // 1. Core scrollable profile sections
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, statusBarHeight + 92, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Concentric glass bio panel with nested refraction borders
                  _buildConcentricBioPanel(context),
                  const SizedBox(height: 28),

                  // 2. Re-architected menu items into clean groups with microscopic eyebrow headers
                  _buildMenuSection(context),
                ],
              ),
            ),

            // 2. Reusable Glassmorphic Top App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: const GlassAppBar(
                showBackButton: false,
                customTitle: 'Sport Pro',
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const GlassBottomBar(currentTab: 'profile'),
    );
  }

  Widget _buildConcentricBioPanel(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
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
                const Color(0xFFF8FAFC).withOpacity(0.8),
              ],
            ),
          ),
          child: Row(
            children: [
              // Styled User Avatar with outer border bezel
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    width: 2.0,
                  ),
                ),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF3F3F8),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDfNUm_0FHTlwMSO97i6w_ybGmHoVLk34xXuVJ138ODeFyymicdmeoElKE4Dw81L669C3EY5e3nBvEaHO2ATTV4XRAbGpQa9oJk7YDslOWIh5l3Cet1fbGGmoW6374uazzBD6RKNWmaZ_9VmgeDnFssIy9zvvN1_YLcGOe8LXyWG63NcbpAyus8mOU5IT6-HZBiyV8msC80n3Zzr4JIoddV8XatdZ_RGD-GClcpI9keO_oHzq8zRr6z6giBAQ6BwerYe3LWlHOp31c',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.person_rounded,
                      size: 32,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Bio Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alex Mercer',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'alex.mercer@sportpro.com',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Concentric glass-styled VIP Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'VIP MEMBER',
                        style: GoogleFonts.spaceMono(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: AppColors.accent,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Compact edit action button
              GestureDetector(
                onTap: () => context.pushNamed(AppRoutes.editProfile),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // GROUP 1: ACCOUNT Eyebrow Header
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

        const SizedBox(height: 24),

        // GROUP 2: PREFERENCES Eyebrow Header
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
}

// Stateful interactive menu row with tactile spring scale micro-physics feedback
class ProfileMenuRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<ProfileMenuRow> createState() => _ProfileMenuRowState();
}

class _ProfileMenuRowState extends State<ProfileMenuRow> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
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
                color: Colors.black.withOpacity(0.01),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
