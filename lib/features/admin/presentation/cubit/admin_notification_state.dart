import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_notification_model.dart';

class AdminNotificationState extends Equatable {
  final List<AdminNotificationModel> notifications;
  final int unreadCount;
  final AdminNotificationModel? latestNotification;
  final String? lastUpdated;

  const AdminNotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.latestNotification,
    this.lastUpdated,
  });

  AdminNotificationState copyWith({
    List<AdminNotificationModel>? notifications,
    int? unreadCount,
    AdminNotificationModel? latestNotification,
    String? lastUpdated,
  }) {
    return AdminNotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      latestNotification: latestNotification ?? this.latestNotification,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        unreadCount,
        latestNotification,
        lastUpdated,
      ];
}
