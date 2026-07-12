import '../../domain/entities/revenue_analytics_entity.dart';

sealed class RevenueAnalyticsState { const RevenueAnalyticsState(); }
class RevenueAnalyticsInitial extends RevenueAnalyticsState { const RevenueAnalyticsInitial(); }
class RevenueAnalyticsLoading extends RevenueAnalyticsState { final RevenueAnalyticsEntity? previous; const RevenueAnalyticsLoading(this.previous); }
class RevenueAnalyticsLoaded extends RevenueAnalyticsState { final RevenueAnalyticsEntity data; const RevenueAnalyticsLoaded(this.data); }
class RevenueAnalyticsError extends RevenueAnalyticsState { final String message; final RevenueAnalyticsEntity? previous; const RevenueAnalyticsError(this.message, this.previous); }
