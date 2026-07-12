import '../models/admin_stats_model.dart';

import '../models/admin_notification_model.dart';
import '../models/revenue_analytics_model.dart';

abstract interface class AdminRemoteDataSource {
  Future<AdminStatsModel> getAdminStats();
  Future<List<AdminNotificationModel>> getAdminNotifications();
  Future<void> markAllNotificationsAsRead();
  Future<RevenueAnalyticsModel> getRevenueAnalytics(DateTime start, DateTime end);
}
