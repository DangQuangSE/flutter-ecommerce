import '../../domain/entities/admin_order_entity.dart';
import 'admin_order_item_model.dart';

class AdminOrderModel extends AdminOrderEntity {
  const AdminOrderModel({
    required super.id,
    required super.shippingAddress,
    required super.phoneNumber,
    super.customerName,
    required super.totalAmount,
    required super.status,
    required super.paymentMethod,
    required super.createdAt,
    required super.items,
  });

  factory AdminOrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List? ?? [];
    return AdminOrderModel(
      id: json['id'] as int,
      shippingAddress: json['shippingAddress'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      customerName: json['customerName'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String? ?? 'PENDING',
      paymentMethod: json['paymentMethod'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: itemsJson
          .map((e) => AdminOrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
