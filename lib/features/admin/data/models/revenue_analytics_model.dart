import '../../domain/entities/revenue_analytics_entity.dart';

class RevenueAnalyticsModel extends RevenueAnalyticsEntity {
  RevenueAnalyticsModel.fromJson(Map<String, dynamic> json) : super(
    startDate: DateTime.parse(json['startDate'] as String), endDate: DateTime.parse(json['endDate'] as String),
    realizedRevenue: _number(json['realizedRevenue']), orderCount: (json['orderCount'] as num).toInt(),
    averageOrderValue: _number(json['averageOrderValue']), previousPeriodRevenue: _number(json['previousPeriodRevenue']),
    growthPercent: json['growthPercent'] == null ? null : _number(json['growthPercent']),
    grouping: RevenueGrouping.values.byName((json['grouping'] as String).toLowerCase()),
    points: (json['points'] as List<dynamic>).map((e) { final p=e as Map<String,dynamic>; return RevenuePointEntity(
      DateTime.parse(p['bucketStart'] as String), DateTime.parse(p['bucketEnd'] as String), _number(p['revenue']), (p['orderCount'] as num).toInt()); }).toList());
  static double _number(Object? value) => value is num ? value.toDouble() : double.parse(value as String);
}
