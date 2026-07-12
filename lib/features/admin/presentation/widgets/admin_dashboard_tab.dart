import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_event.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_state.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_state.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/revenue_analytics_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/revenue_analytics_state.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/revenue_analytics_entity.dart';

enum _RevenuePeriod { week, month, year, custom }

class AdminDashboardTab extends StatelessWidget {
  final AdminLoaded state;

  const AdminDashboardTab({super.key, required this.state});

  Future<void> _handleRefresh(BuildContext context) async {
    context.read<AdminBloc>().add(const AdminStatsRequested());
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    await context.read<RevenueAnalyticsCubit>().load(start, now);
  }

  @override
  Widget build(BuildContext context) {
    final stats = state.stats;
    final revenueState = context.watch<RevenueAnalyticsCubit>().state;
    final revenue = switch (revenueState) {
      RevenueAnalyticsLoaded(:final data) => data,
      RevenueAnalyticsLoading(:final previous) => previous,
      RevenueAnalyticsError(:final previous) => previous,
      _ => null,
    };
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: () => _handleRefresh(context),
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
                    AppStrings.adminDashboardAppName,
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
                    _notificationBellButton(context),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.adminDashboardStatisticsLabel,
                  style: GoogleFonts.lexend(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            if (revenueState is RevenueAnalyticsLoading)
              const LinearProgressIndicator(),
            if (revenueState is RevenueAnalyticsError)
              Card(
                  child: ListTile(
                title: Text(revenueState.message),
                subtitle: Text(revenueState.previous == null
                    ? AppStrings.adminRevenueErrorNoData
                    : AppStrings.adminRevenueErrorWithPrevious),
                trailing: TextButton(
                    onPressed: context.read<RevenueAnalyticsCubit>().refresh,
                    child: const Text(AppStrings.adminRevenueRetry)),
              )),
            if (revenue != null && revenue.points.isEmpty)
              const Text(AppStrings.adminRevenueEmptyRange),

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
                        AppStrings.adminRevenueLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        revenue == null
                            ? AppStrings.adminRevenueLoading
                            : currencyFormat
                                .format(double.parse(revenue.realizedRevenue)),
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
                            _growthText(revenue?.growthPercent),
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
            if (revenue != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.adminRevenueRangeText(
                        DateFormat('dd/MM/yyyy').format(revenue.startDate),
                        DateFormat('dd/MM/yyyy').format(revenue.endDate),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showPeriodFilter(context, revenue),
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text(AppStrings.adminRevenueFilter),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // KPI row
            Row(
              children: [
                Expanded(
                    child: _kpiCard(
                  context: context,
                  label: AppStrings.adminOrdersCountLabel,
                  value: '${revenue?.orderCount ?? stats.totalOrders}',
                  growth: revenue == null
                      ? '+${stats.ordersGrowth}%'
                      : AppStrings.adminOrdersSelectedPeriod,
                  icon: Icons.local_shipping_outlined,
                  iconColor: AppColors.primary,
                )),
                SizedBox(width: 12),
                Expanded(
                    child: _kpiCard(
                  context: context,
                  label: AppStrings.adminNewCustomersLabel,
                  value: '${stats.newCustomers}',
                  growth: '+${stats.customersGrowth}%',
                  icon: Icons.people_alt_outlined,
                  iconColor: Colors.orange,
                )),
              ],
            ),
            SizedBox(height: 24),

            // Traffic chart removed as requested
          ],
        ),
      ),
    );
  }

  String _growthText(String? growthPercent) {
    if (growthPercent == null) return AppStrings.adminRevenueGrowthNone;
    final sign = growthPercent.startsWith('-') ? '' : '+';
    return '$sign$growthPercent% ${AppStrings.adminRevenueGrowthSuffix}';
  }

  Future<void> _showPeriodFilter(
    BuildContext context,
    RevenueAnalyticsEntity revenue,
  ) async {
    final choice = await showModalBottomSheet<_RevenuePeriod>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                AppStrings.adminRevenueFilterTitle,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            _periodTile(sheetContext, _RevenuePeriod.week,
                AppStrings.adminRevenuePresetThisWeek),
            _periodTile(sheetContext, _RevenuePeriod.month,
                AppStrings.adminRevenuePresetThisMonth),
            _periodTile(sheetContext, _RevenuePeriod.year,
                AppStrings.adminRevenuePresetThisYear),
            _periodTile(sheetContext, _RevenuePeriod.custom,
                AppStrings.adminRevenuePresetCustom),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;

    final now = DateTime.now();
    switch (choice) {
      case _RevenuePeriod.week:
        final start = now.subtract(Duration(days: now.weekday - 1));
        await context.read<RevenueAnalyticsCubit>().load(start, now);
      case _RevenuePeriod.month:
        await context
            .read<RevenueAnalyticsCubit>()
            .load(DateTime(now.year, now.month), now);
      case _RevenuePeriod.year:
        await context
            .read<RevenueAnalyticsCubit>()
            .load(DateTime(now.year), now);
      case _RevenuePeriod.custom:
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 5, now.month, now.day),
          lastDate: now,
          initialDateRange: DateTimeRange(
            start: revenue.startDate,
            end: revenue.endDate,
          ),
        );
        if (picked != null && context.mounted) {
          await context
              .read<RevenueAnalyticsCubit>()
              .load(picked.start, picked.end);
        }
    }
  }

  Widget _periodTile(
    BuildContext context,
    _RevenuePeriod period,
    String label,
  ) =>
      ListTile(
        title: Text(label),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => Navigator.pop(context, period),
      );

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
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
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
    required BuildContext context,
    required String label,
    required String value,
    required String growth,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor),
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

  Widget _notificationBellButton(BuildContext context) {
    return BlocBuilder<AdminNotificationCubit, AdminNotificationState>(
      builder: (context, state) {
        final unread = state.unreadCount;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () {
                context.read<AdminNotificationCubit>().markAllAsRead();
                _showNotificationsSheet(context, state);
              },
              icon: Icon(Icons.notifications_none_rounded,
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
                      const BoxConstraints(minWidth: 16, minHeight: 16),
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

  void _showNotificationsSheet(
      BuildContext context, AdminNotificationState state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.adminNotificationSheetTitle,
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              if (state.notifications.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    AppStrings.adminNotificationEmpty,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final notif = state.notifications[index];
                      return Opacity(
                          opacity: notif.isRead ? 0.6 : 1.0,
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (!notif.isRead)
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              notif.title.isNotEmpty
                                  ? notif.title
                                  : AppStrings.adminNotificationDefaultTitle,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: notif.isRead
                                    ? FontWeight.w500
                                    : FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notif.message,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  AppStrings.adminNotificationOrderText(
                                      notif.orderId, notif.createdAt),
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              context.pushNamed(
                                AppRoutes.adminOrderDetail,
                                pathParameters: {
                                  'orderId': notif.orderId.toString()
                                },
                              );
                            },
                          ));
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
