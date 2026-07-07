import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_ecommerce/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_state.dart';
import 'package:flutter_ecommerce/features/notification/data/datasources/notification_socket_client.dart';
import 'package:flutter_ecommerce/core/utils/notification_service.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final NotificationRepository _repository;
  final NotificationSocketClient _socketClient;
  final NotificationService _notificationService;
  StreamSubscription? _subscription;

  NotificationCubit({
    required GetNotificationsUseCase getNotificationsUseCase,
    required NotificationRepository repository,
    required NotificationSocketClient socketClient,
    required NotificationService notificationService,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _repository = repository,
        _socketClient = socketClient,
        _notificationService = notificationService,
        super(const NotificationInitial()) {
    _socketClient.connect();
    _subscription = _socketClient.notifications.listen((notification) {
      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        final updatedNotifications = [notification, ...currentState.notifications];
        emit(NotificationLoaded(updatedNotifications));
      } else {
        // If not loaded yet, just load them from API
        loadNotifications();
      }
      
      _notificationService.showNotification(
        id: notification.id,
        title: notification.title,
        body: notification.description,
        payload: '/orders/${notification.relatedId}', // Navigation payload
      );
    });
  }

  Future<void> loadNotifications() async {
    emit(const NotificationLoading());
    final result = await _getNotificationsUseCase();
    switch (result) {
      case Success(:final data):
        emit(NotificationLoaded(data));
      case ResultFailure(:final failure):
        emit(NotificationError(failure.message));
    }
  }

  Future<void> markAsRead(int id) async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = currentState.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      emit(NotificationLoaded(updatedNotifications));
    }
    await _repository.markAsRead(id);
  }

  Future<void> markAllAsRead() async {
    if (state is NotificationLoaded) {
      final currentState = state as NotificationLoaded;
      final updatedNotifications = currentState.notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
      emit(NotificationLoaded(updatedNotifications));
    }
    await _repository.markAllAsRead();
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    _socketClient.dispose();
    return super.close();
  }
}
