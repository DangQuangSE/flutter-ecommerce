import 'package:flutter_ecommerce/core/errors/result.dart';
import '../entities/admin_stats_entity.dart';

import 'package:flutter_ecommerce/features/admin/data/models/admin_notification_model.dart';
import '../entities/revenue_analytics_entity.dart';

abstract interface class AdminRepository {
  Future<Result<AdminStatsEntity>> getAdminStats();
  Future<Result<List<AdminNotificationModel>>> getAdminNotifications();
  Future<Result<void>> markAllAdminNotificationsAsRead();
  Future<Result<RevenueAnalyticsEntity>> getRevenueAnalytics(
      DateTime start, DateTime end);
}
