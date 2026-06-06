import '../../domain/entities/admin_stats_entity.dart';
import 'recent_order_model.dart';

class AdminStatsModel extends AdminStatsEntity {
  const AdminStatsModel({
    required super.totalRevenue,
    required super.revenueGrowth,
    required super.totalOrders,
    required super.ordersGrowth,
    required super.newCustomers,
    required super.customersGrowth,
    required super.weeklyTraffic,
    required super.recentOrders,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) => AdminStatsModel(
        totalRevenue: (json['total_revenue'] as num).toDouble(),
        revenueGrowth: (json['revenue_growth'] as num).toDouble(),
        totalOrders: json['total_orders'] as int,
        ordersGrowth: (json['orders_growth'] as num).toDouble(),
        newCustomers: json['new_customers'] as int,
        customersGrowth: (json['customers_growth'] as num).toDouble(),
        weeklyTraffic: (json['weekly_traffic'] as List<dynamic>)
            .map((e) => (e as num).toDouble())
            .toList(),
        recentOrders: (json['recent_orders'] as List<dynamic>)
            .map((e) => RecentOrderModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static AdminStatsModel get mockStats => AdminStatsModel(
        totalRevenue: 24500000.0, // 24.5M
        revenueGrowth: 12.8,       // +12.8%
        totalOrders: 142,          // 142 orders
        ordersGrowth: 8.0,         // +8%
        newCustomers: 38,          // 38 new customers
        customersGrowth: 2.4,      // +2.4%
        weeklyTraffic: const [30, 45, 80, 50, 60, 40, 70], // Sunday to Saturday or similar
        recentOrders: [
          RecentOrderModel(
            id: 'o-001',
            orderCode: 'SĐHĐ-0821',
            productName: 'Giày Chạy Bộ Pro X1',
            rawStatus: 'SHIPPED',
            status: 'Đang giao',
            price: 2690000.0,
            date: DateTime.now(),
          ),
          RecentOrderModel(
            id: 'o-002',
            orderCode: 'SĐHĐ-0820',
            productName: 'Áo Thun Cao Cấp Sg...',
            rawStatus: 'PENDING',
            status: 'Chờ xác nhận',
            price: 545000.0,
            date: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          RecentOrderModel(
            id: 'o-003',
            orderCode: 'SĐHĐ-0819',
            productName: 'Mũ Bảo Hiểm Khi Động...',
            rawStatus: 'DELIVERED',
            status: 'Đã giao',
            price: 1200000.0,
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      );
}
