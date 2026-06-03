import 'package:flutter_ecommerce/core/errors/result.dart';
import '../entities/admin_stats_entity.dart';

abstract interface class AdminRepository {
  Future<Result<AdminStatsEntity>> getAdminStats();
}
