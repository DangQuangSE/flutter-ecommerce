import 'package:equatable/equatable.dart';
import 'recent_order_entity.dart';

class AdminStatsEntity extends Equatable {
  final double totalRevenue;
  final double revenueGrowth;
  final int totalOrders;
  final double ordersGrowth;
  final int newCustomers;
  final double customersGrowth;
  final List<double> weeklyTraffic; // 7 numbers representing traffic levels
  final List<RecentOrderEntity> recentOrders;

  const AdminStatsEntity({
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.totalOrders,
    required this.ordersGrowth,
    required this.newCustomers,
    required this.customersGrowth,
    required this.weeklyTraffic,
    required this.recentOrders,
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        revenueGrowth,
        totalOrders,
        ordersGrowth,
        newCustomers,
        customersGrowth,
        weeklyTraffic,
        recentOrders,
      ];
}
