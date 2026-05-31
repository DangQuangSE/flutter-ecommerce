import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/notification/domain/repositories/notification_repository.dart';
import 'package:flutter_ecommerce/features/notification/domain/usecases/get_notifications_usecase.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final GetNotificationsUseCase _getNotificationsUseCase;
  final NotificationRepository _repository;

  NotificationCubit({
    required GetNotificationsUseCase getNotificationsUseCase,
    required NotificationRepository repository,
  })  : _getNotificationsUseCase = getNotificationsUseCase,
        _repository = repository,
        super(const NotificationInitial());

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

  Future<void> markAsRead(String id) async {
    final result = await _repository.markAsRead(id);
    if (result is Success) {
      await loadNotifications();
    }
  }

  Future<void> markAllAsRead() async {
    final result = await _repository.markAllAsRead();
    if (result is Success) {
      await loadNotifications();
    }
  }
}
