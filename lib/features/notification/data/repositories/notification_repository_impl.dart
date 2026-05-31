import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/notification/data/models/notification_model.dart';
import 'package:flutter_ecommerce/features/notification/domain/entities/notification_entity.dart';
import 'package:flutter_ecommerce/features/notification/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  // In-memory data store for live unread updates
  final List<NotificationEntity> _items = List.from(NotificationModel.mockList);

  @override
  Future<Result<List<NotificationEntity>>> getNotifications() async {
    return Success(List.unmodifiable(_items));
  }

  @override
  Future<Result<void>> markAsRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    for (int i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
    return const Success(null);
  }
}
