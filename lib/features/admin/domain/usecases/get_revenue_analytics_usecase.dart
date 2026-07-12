import '../../../../core/errors/result.dart';
import '../entities/revenue_analytics_entity.dart';
import '../repositories/admin_repository.dart';

class GetRevenueAnalyticsUseCase {
  final AdminRepository repository;
  const GetRevenueAnalyticsUseCase(this.repository);
  Future<Result<RevenueAnalyticsEntity>> call(DateTime start, DateTime end) => repository.getRevenueAnalytics(start, end);
}
