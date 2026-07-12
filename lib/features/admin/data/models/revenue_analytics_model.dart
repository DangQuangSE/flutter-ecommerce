import '../../domain/entities/revenue_analytics_entity.dart';

class RevenueAnalyticsModel extends RevenueAnalyticsEntity {
  RevenueAnalyticsModel.fromJson(Map<String, dynamic> json)
      : super(
            startDate: _date(json['startDate']),
            endDate: _date(json['endDate']),
            realizedRevenue: _decimal(json, 'realizedRevenue'),
            orderCount: _integer(json, 'orderCount'),
            averageOrderValue: _decimal(json, 'averageOrderValue'),
            previousPeriodRevenue: _decimal(json, 'previousPeriodRevenue'),
            growthPercent: json['growthPercent'] == null
                ? null
                : _decimal(json, 'growthPercent'),
            grouping: _grouping(json['grouping']),
            points: _points(json['points']));
  static String _decimal(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num && value is! String) {
      throw FormatException('Invalid $key');
    }
    final text = value.toString();
    if (num.tryParse(text) == null) {
      throw FormatException('Invalid $key');
    }
    return text;
  }

  static int _integer(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is! num) {
      throw FormatException('Invalid $key');
    }
    return value.toInt();
  }

  static DateTime _date(Object? value) {
    if (value is! String) {
      throw const FormatException('Invalid date');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw const FormatException('Invalid date');
    }
    return parsed;
  }

  static RevenueGrouping _grouping(Object? value) {
    if (value is! String) {
      throw const FormatException('Invalid grouping');
    }
    for (final item in RevenueGrouping.values) {
      if (item.name == value.toLowerCase()) {
        return item;
      }
    }
    throw const FormatException('Invalid grouping');
  }

  static List<RevenuePointEntity> _points(Object? value) {
    if (value is! List) {
      throw const FormatException('Invalid points');
    }
    return value.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Invalid point');
      }
      return RevenuePointEntity(
          _date(item['bucketStart']),
          _date(item['bucketEnd']),
          _decimal(item, 'revenue'),
          _integer(item, 'orderCount'));
    }).toList(growable: false);
  }
}
