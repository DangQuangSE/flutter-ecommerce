enum RevenueGrouping { daily, weekly, monthly }

class RevenuePointEntity {
  final DateTime bucketStart, bucketEnd;
  final double revenue;
  final int orderCount;
  const RevenuePointEntity(this.bucketStart, this.bucketEnd, this.revenue, this.orderCount);
}

class RevenueAnalyticsEntity {
  final DateTime startDate, endDate;
  final double realizedRevenue, averageOrderValue, previousPeriodRevenue;
  final double? growthPercent;
  final int orderCount;
  final RevenueGrouping grouping;
  final List<RevenuePointEntity> points;
  const RevenueAnalyticsEntity({required this.startDate, required this.endDate, required this.realizedRevenue,
    required this.orderCount, required this.averageOrderValue, required this.previousPeriodRevenue,
    required this.growthPercent, required this.grouping, required this.points});
}
