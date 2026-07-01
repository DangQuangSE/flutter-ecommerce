import '../../domain/entities/admin_stats_entity.dart';

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalRevenue,
    required super.revenueGrowth,
    required super.totalOrders,
    required super.ordersGrowth,
    required super.newCustomers,
    required super.customersGrowth,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      AdminStatsModel(
        totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
        revenueGrowth: (json['revenueGrowth'] as num?)?.toDouble() ?? 0.0,
        totalOrders: json['totalOrders'] as int? ?? 0,
        ordersGrowth: (json['ordersGrowth'] as num?)?.toDouble() ?? 0.0,
        newCustomers: json['newCustomers'] as int? ?? 0,
        customersGrowth: (json['customersGrowth'] as num?)?.toDouble() ?? 0.0,
      );

  static AdminStatsModel get mockStats => const AdminStatsModel(
        totalRevenue: 24500000.0, // 24.5M
        revenueGrowth: 12.8, // +12.8%
        totalOrders: 142, // 142 orders
        ordersGrowth: 8.0, // +8%
        newCustomers: 38, // 38 new customers
        customersGrowth: 2.4, // +2.4%
      );
}
