import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/admin/domain/repositories/admin_repository.dart';

class MarkAllAdminNotificationsAsReadUseCase {
  final AdminRepository repository;

  MarkAllAdminNotificationsAsReadUseCase(this.repository);

  Future<Result<void>> call() async {
    return await repository.markAllAdminNotificationsAsRead();
  }
}
