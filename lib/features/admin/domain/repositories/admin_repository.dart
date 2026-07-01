import 'package:flutter_ecommerce/core/errors/result.dart';
import '../entities/admin_stats_entity.dart';

import 'package:flutter_ecommerce/features/admin/data/models/admin_notification_model.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_stats_model.dart';

abstract interface class AdminRepository {
  Future<Result<AdminStatsEntity>> getAdminStats();
  Future<Result<List<AdminNotificationModel>>> getAdminNotifications();
  Future<Result<void>> markAllAdminNotificationsAsRead();
}
