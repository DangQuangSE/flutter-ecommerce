import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/notification/domain/entities/notification_entity.dart';
import 'package:flutter_ecommerce/features/notification/domain/repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository _repository;

  const GetNotificationsUseCase(this._repository);

  Future<Result<List<NotificationEntity>>> call() => _repository.getNotifications();
}
