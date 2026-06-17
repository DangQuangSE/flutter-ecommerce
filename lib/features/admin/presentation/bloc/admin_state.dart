import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_order_entity.dart';
import 'package:flutter_ecommerce/features/admin/domain/entities/admin_stats_entity.dart';
import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

sealed class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminLoaded extends AdminState {
  final AdminStatsEntity stats;
  final List<ProductEntity> products;
  final List<AdminOrderEntity> recentOrders;
  final String? message; // Optional success message for operations

  const AdminLoaded({
    required this.stats,
    required this.products,
    this.recentOrders = const [],
    this.message,
  });

  AdminLoaded copyWith({
    AdminStatsEntity? stats,
    List<ProductEntity>? products,
    List<AdminOrderEntity>? recentOrders,
    String? message,
  }) {
    return AdminLoaded(
      stats: stats ?? this.stats,
      products: products ?? this.products,
      recentOrders: recentOrders ?? this.recentOrders,
      message: message,
    );
  }

  @override
  List<Object?> get props => [stats, products, recentOrders, message];
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}
