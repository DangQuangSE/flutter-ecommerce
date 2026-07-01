import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_state.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';

class AdminDashboardTab extends StatelessWidget {
  final AdminLoaded state;

  const AdminDashboardTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final stats = state.stats;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
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
                  _chatInboxButton(context),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.notifications_none_rounded,
                        color: AppColors.textPrimary),
                  ),
                  const CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(
                        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e'),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),

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
                  SizedBox(height: 2),
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
                child: Icon(Icons.calendar_today_rounded,
                    size: 16, color: AppColors.textPrimary),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Revenue block
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
                  color: AppColors.primary.withValues(alpha: 0.2),
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
                        color: Colors.white.withValues(alpha: 0.8),
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 8),
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
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded,
                            size: 12,
                            color: Colors.white.withValues(alpha: 0.9)),
                        SizedBox(width: 2),
                        Text(
                          '+${stats.revenueGrowth}% so với tuần trước',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.account_balance_wallet_rounded,
                      size: 28, color: Colors.white),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),

          // KPI row
          Row(
            children: [
              Expanded(
                  child: _kpiCard(
                label: 'ĐƠN HÀNG',
                value: '${stats.totalOrders}',
                growth: '+${stats.ordersGrowth}% tuần này',
                icon: Icons.local_shipping_outlined,
                iconColor: AppColors.primary,
              )),
              SizedBox(width: 12),
              Expanded(
                  child: _kpiCard(
                label: 'KHÁCH MỚI',
                value: '${stats.newCustomers}',
                growth: '+${stats.customersGrowth}%',
                icon: Icons.people_alt_outlined,
                iconColor: Colors.orange,
              )),
            ],
          ),
          SizedBox(height: 24),

          // Traffic chart
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                          Icon(Icons.keyboard_arrow_down_rounded,
                              size: 12, color: AppColors.textPrimary),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _barChart(context, stats.weeklyTraffic),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatInboxButton(BuildContext context) {
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
              icon: Icon(Icons.chat_bubble_outline_rounded,
                  color: AppColors.textPrimary),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  constraints:
                      BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _kpiCard({
    required String label,
    required String value,
    required String growth,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
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
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8)),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          SizedBox(height: 8),
          Text(value,
              style: GoogleFonts.lexend(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text(growth,
              style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success)),
        ],
      ),
    );
  }

  Widget _barChart(BuildContext context, List<double> traffic) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const double maxHeight = 100.0;
    final maxTraffic = traffic.reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(traffic.length, (index) {
            final val = traffic[index];
            final height =
                maxTraffic > 0 ? (val / maxTraffic) * maxHeight : 10.0;
            final bool isHighlighted = index == 2;

            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Lưu lượng ${days[index]}: ${val.toInt()}%'),
                      duration: const Duration(milliseconds: 600),
                      backgroundColor: AppColors.primary,
                    ));
                  },
                  child: Container(
                    width: 24,
                    height: height,
                    decoration: BoxDecoration(
                      color: isHighlighted
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.25),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  days[index],
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight:
                        isHighlighted ? FontWeight.w700 : FontWeight.w500,
                    color: isHighlighted
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
