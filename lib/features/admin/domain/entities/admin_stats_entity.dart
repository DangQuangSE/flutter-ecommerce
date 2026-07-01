import 'package:equatable/equatable.dart';

class AdminStatsEntity extends Equatable {
  final double totalRevenue;
  final double revenueGrowth;
  final int totalOrders;
  final double ordersGrowth;
  final int newCustomers;
  final double customersGrowth;

  const AdminStatsEntity({
    required this.totalRevenue,
    required this.revenueGrowth,
    required this.totalOrders,
    required this.ordersGrowth,
    required this.newCustomers,
    required this.customersGrowth,
  });

  @override
  List<Object?> get props => [
        totalRevenue,
        revenueGrowth,
        totalOrders,
        ordersGrowth,
        newCustomers,
        customersGrowth,
      ];
}
