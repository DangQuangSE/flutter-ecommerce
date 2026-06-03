import 'package:flutter_ecommerce/core/errors/result.dart';
import '../entities/admin_stats_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminStatsUseCase {
  final AdminRepository _repository;
  const GetAdminStatsUseCase(this._repository);

  Future<Result<AdminStatsEntity>> call() => _repository.getAdminStats();
}
