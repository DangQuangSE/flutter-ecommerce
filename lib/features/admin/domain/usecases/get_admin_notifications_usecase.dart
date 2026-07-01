import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/data/models/admin_notification_model.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_repository.dart';

class GetAdminNotificationsUseCase {
  final AdminRepository repository;

  GetAdminNotificationsUseCase(this.repository);

  Future<Result<List<AdminNotificationModel>>> call() async {
    return await repository.getAdminNotifications();
  }
}
