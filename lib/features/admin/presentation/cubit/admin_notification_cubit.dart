import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_socket_client.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_state.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/get_admin_notifications_usecase.dart';
import 'package:flutter_ecommerce/features/admin/domain/usecases/mark_all_admin_notifications_as_read_usecase.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_notification_model.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';

class AdminNotificationCubit extends Cubit<AdminNotificationState> {
  final AdminSocketClient _socketClient;
  final GetAdminNotificationsUseCase _getNotificationsUseCase;
  final MarkAllAdminNotificationsAsReadUseCase _markAllAsReadUseCase;
  StreamSubscription? _subscription;

  AdminNotificationCubit(
    this._socketClient,
    this._getNotificationsUseCase,
    this._markAllAsReadUseCase,
  ) : super(const AdminNotificationState()) {
    _loadInitialNotifications();

    _socketClient.connect();
    _subscription = _socketClient.notifications.listen((notification) {
      final updatedNotifications = [notification, ...state.notifications];
      emit(state.copyWith(
        notifications: updatedNotifications,
        unreadCount: state.unreadCount + 1,
        latestNotification: notification,
        lastUpdated: DateTime.now().toIso8601String(),
      ));
    });
  }

  Future<void> _loadInitialNotifications() async {
    final result = await _getNotificationsUseCase();
    if (result is Success<List<AdminNotificationModel>>) {
      final notifications = result.data;
      final unreadCount = notifications.where((n) => !n.isRead).length;
      emit(state.copyWith(
        notifications: notifications,
        unreadCount: unreadCount,
        lastUpdated: DateTime.now().toIso8601String(),
      ));
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic update
    final updated = state.notifications
        .map((n) => AdminNotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              isRead: true,
              orderId: n.orderId,
              customerName: n.customerName,
              createdAt: n.createdAt,
            ))
        .toList();
    emit(state.copyWith(unreadCount: 0, notifications: updated));

    final result = await _markAllAsReadUseCase();
    if (result is Success) {
      // Already updated optimistically, but we could reload from API if needed.
    }
  }

  void connect() {
    _socketClient.connect();
  }

  void disconnect() {
    _socketClient.disconnect();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _socketClient.dispose();
    return super.close();
  }
}
