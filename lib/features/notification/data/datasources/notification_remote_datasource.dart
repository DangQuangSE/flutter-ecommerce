import 'package:flutter_ecommerce/features/notification/data/models/notification_model.dart';

abstract interface class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> markAsRead(int id);
}
