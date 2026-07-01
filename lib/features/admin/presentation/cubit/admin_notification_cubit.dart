import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/features/admin/data/datasources/admin_socket_client.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_state.dart';

class AdminNotificationCubit extends Cubit<AdminNotificationState> {
  final AdminSocketClient _socketClient;
  StreamSubscription? _subscription;

  AdminNotificationCubit(this._socketClient)
      : super(const AdminNotificationState()) {
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

  void markAllAsRead() {
    emit(state.copyWith(unreadCount: 0));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _socketClient.dispose();
    return super.close();
  }
}
