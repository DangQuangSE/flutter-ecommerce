import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_state.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/recent_order_entity.dart';
import 'package:flutter_ecommerce/core/utils/order_status_label.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load the support inbox (admin → all conversations) and open the realtime
    // socket so new customer messages arrive live + the unread badge updates.
    context.read<ChatCubit>().loadChats();
  }

  /// Header button → support chat inbox, with a live unread badge.
  Widget _buildChatInboxButton(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final unread = state is ChatsLoaded
            ? state.chats.fold<int>(0, (sum, c) => sum + c.unreadCount)
            : 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => context.pushNamed(AppRoutes.chatList),
              icon: const Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.textPrimary),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (state is AdminLoaded) {
            return IndexedStack(
              index: _currentIndex,
              children: [
                _buildDashboardTab(context, state),
                _buildManagementTab(context),
                _buildLocationTab(context),
                _buildProfileTab(context),
              ],
            );
          }

          return const Center(
            child: Text('Đã xảy ra lỗi khi tải dữ liệu Admin.'),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary.withOpacity(0.7),
          selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 11),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded, size: 22),
              activeIcon: Icon(Icons.dashboard_rounded, size: 24),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tune_rounded, size: 22),
              activeIcon: Icon(Icons.tune_rounded, size: 24),
              label: 'Quản lý',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_rounded, size: 22),
              activeIcon: Icon(Icons.location_on_rounded, size: 24),
              label: 'Cửa hàng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 22),
              activeIcon: Icon(Icons.person_rounded, size: 24),
              label: 'Cá nhân',
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 1: Dashboard ────────────────────────────────────────────────────────
  Widget _buildDashboardTab(BuildContext context, AdminLoaded state) {
    final stats = state.stats;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final shortCurrencyFormat = NumberFormat.compact(locale: 'vi_VN');

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Transform(
                transform: Matrix4.skewX(-0.12),
                alignment: Alignment.center,
                child: Text(
                  'Sport Pro',
                  style: GoogleFonts.lexend(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
              Row(
                children: [
                  _buildChatInboxButton(context),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://images.unsplash.com/photo-1472099645785-5658abf4ff4e'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Dashboard title section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: GoogleFonts.lexend(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Hôm nay, 01 Tháng 6',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Primary Blue Revenue Block
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DOANH THU',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      stats.totalRevenue >= 1000000 
                          ? '${(stats.totalRevenue / 1000000).toStringAsFixed(1)}M'
                          : currencyFormat.format(stats.totalRevenue),
                      style: GoogleFonts.lexend(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded, size: 12, color: Colors.white.withOpacity(0.9)),
                        const SizedBox(width: 2),
                        Text(
                          '+${stats.revenueGrowth}% so với tuần trước',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, size: 28, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Secondary KPI Grid (Orders, New Customers)
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ĐƠN HÀNG',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Icon(Icons.local_shipping_outlined, size: 16, color: AppColors.primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.totalOrders}',
                        style: GoogleFonts.lexend(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${stats.ordersGrowth}% tuần này',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'KHÁCH MỚI',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const Icon(Icons.people_alt_outlined, size: 16, color: Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats.newCustomers}',
                        style: GoogleFonts.lexend(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+${stats.customersGrowth}%',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Traffic Chart Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lưu lượng truy cập',
                      style: GoogleFonts.lexend(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'TUẦN NÀY',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, size: 12, color: AppColors.textPrimary),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Native custom Bar Chart widget
                _buildBarChart(stats.weeklyTraffic),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Orders Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đơn hàng gần đây',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed(AppRoutes.adminOrders),
                child: Text(
                  'XEM TẤT CẢ',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Recent Orders List
          ...stats.recentOrders.map(
            (order) => _buildRecentOrderCard(context, order, shortCurrencyFormat),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<double> traffic) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final double maxHeight = 100.0;
    
    // Find maximum traffic value to scale chart appropriately
    final maxTraffic = traffic.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(traffic.length, (index) {
            final val = traffic[index];
            final height = maxTraffic > 0 ? (val / maxTraffic) * maxHeight : 10.0;
            // Highlight T4 as in the mock image
            final bool isHighlighted = index == 2; 

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lưu lượng ${days[index]}: ${val.toInt()}%'),
                        duration: const Duration(milliseconds: 600),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  child: Container(
                    width: 24,
                    height: height,
                    decoration: BoxDecoration(
                      color: isHighlighted ? AppColors.primary : AppColors.primary.withOpacity(0.25),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  days[index],
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w500,
                    color: isHighlighted ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildRecentOrderCard(BuildContext context, RecentOrderEntity order, NumberFormat format) {
    final (badgeBg, badgeText) = OrderStatusLabel.badgeColors(order.rawStatus);

    return GestureDetector(
      onTap: () => context.pushNamed(
        AppRoutes.adminOrderDetail,
        pathParameters: {'orderId': order.id},
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2_rounded, size: 20, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.orderCode,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.productName,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                format.format(order.price),
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.status,
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }

  // ── Tab 2: Management Hub ───────────────────────────────────────────────────
  Widget _buildManagementTab(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          Text(
            'Quản lý',
            style: GoogleFonts.lexend(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Truy cập nhanh các mục quản trị',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildManagementItem(
                  context,
                  icon: Icons.shopping_bag_rounded,
                  label: 'Quản lý Sản phẩm',
                  onTap: () => context.pushNamed(AppRoutes.adminProductList),
                ),
                const Divider(height: 1),
                _buildManagementItem(
                  context,
                  icon: Icons.branding_watermark_rounded,
                  label: 'Quản lý Thương hiệu',
                  onTap: () => context.pushNamed(AppRoutes.adminBrands),
                ),
                const Divider(height: 1),
                _buildManagementItem(
                  context,
                  icon: Icons.color_lens_rounded,
                  label: 'Quản lý Màu sắc',
                  onTap: () => context.pushNamed(AppRoutes.adminColors),
                ),
                const Divider(height: 1),
                _buildManagementItem(
                  context,
                  icon: Icons.category_rounded,
                  label: 'Quản lý Danh mục',
                  onTap: () => context.pushNamed(AppRoutes.adminCategories),
                ),
                const Divider(height: 1),
                _buildManagementItem(
                  context,
                  icon: Icons.local_offer_rounded,
                  label: 'Quản lý Mã giảm giá',
                  onTap: () => context.pushNamed(AppRoutes.adminCoupons),
                ),
                const Divider(height: 1),
                _buildManagementItem(
                  context,
                  icon: Icons.support_agent_rounded,
                  label: 'Tin nhắn hỗ trợ',
                  onTap: () => context.pushNamed(AppRoutes.chatList),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }


  // ── Tab 3: Showroom Location ────────────────────────────────────────────────
  Widget _buildLocationTab(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 0; // Go back to dashboard
                    });
                  },
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
                ),
                const SizedBox(width: 16),
                Text(
                  'Vị trí của cửa hàng',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Map Mock Container
          Expanded(
            child: Stack(
              children: [
                // 1. Beautiful Mock Map display using Canvas/Grid
                Container(
                  color: const Color(0xFFE5E7EB),
                  child: Stack(
                    children: [
                      // Grid/Road overlay mocks
                      Positioned.fill(
                        child: CustomPaint(
                          painter: MapMockGridPainter(),
                        ),
                      ),
                      // Center pin location animation
                      Center(
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 800),
                          curve: Curves.elasticOut,
                          builder: (context, val, child) {
                            return Transform.translate(
                              offset: Offset(0, -20 * (1.0 - val)),
                              child: Transform.scale(
                                scale: val,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.12),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                      child: Text(
                                        'Sport Pro Showroom',
                                        style: GoogleFonts.inter(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 48,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Details Showroom overlay bottom sheet
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SHOWROOM',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sport Pro Showroom',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Info lines
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.location_on_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '123 Nguyễn Văn Linh, Quận 7, TP. Hồ Chí Minh',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.phone_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              '0909 123 456',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time_filled_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              '08:00 - 21:00',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 4: Profile & Logout ─────────────────────────────────────────────────
  Widget _buildProfileTab(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                    child: user?.avatarUrl == null
                        ? const Icon(Icons.person_rounded, size: 48, color: AppColors.primary)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_user_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                user?.name ?? 'Admin Sport Pro',
                style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Center(
              child: Text(
                user?.email ?? 'admin@sportpro.com',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'QUẢN TRỊ VIÊN',
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Main Actions list
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.store_mall_directory_rounded, color: AppColors.primary),
                    title: Text('Về Cửa hàng (User View)', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () {
                      context.goNamed(AppRoutes.productList);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                    title: Text('Đăng xuất tài khoản', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.error)),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.error),
                    onTap: () {
                      context.read<AuthBloc>().add(const AuthLogoutRequested());
                    },
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

// Custom Painter to draw a highly stylized mock map background
class MapMockGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 24.0
      ..strokeCap = StrokeCap.round;

    final secondaryRoadPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..strokeWidth = 14.0
      ..strokeCap = StrokeCap.round;

    final riverPaint = Paint()
      ..color = const Color(0xFFBAE6FD)
      ..strokeWidth = 40.0
      ..strokeCap = StrokeCap.round;

    // Draw river
    final riverPath = Path()
      ..moveTo(0, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.2, size.width * 0.8, size.height * 0.5)
      ..lineTo(size.width, size.height * 0.55);
    canvas.drawPath(riverPath, riverPaint);

    // Draw main roads
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), roadPaint);
    canvas.drawLine(Offset(size.width * 0.4, 0), Offset(size.width * 0.4, size.height), roadPaint);

    // Draw sub roads
    canvas.drawLine(Offset(0, size.height * 0.8), Offset(size.width, size.height * 0.75), secondaryRoadPaint);
    canvas.drawLine(Offset(size.width * 0.75, 0), Offset(size.width * 0.75, size.height), secondaryRoadPaint);
    canvas.drawLine(Offset(0, size.height * 0.1), Offset(size.width * 0.5, size.height * 0.35), secondaryRoadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
