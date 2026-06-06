import '../../domain/entities/recent_order_entity.dart';

class RecentOrderModel extends RecentOrderEntity {
  const RecentOrderModel({
    required super.id,
    required super.orderCode,
    required super.productName,
    required super.rawStatus,
    required super.status,
    required super.price,
    required super.date,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) => RecentOrderModel(
        id: json['id'] as String,
        orderCode: json['order_code'] as String,
        productName: json['product_name'] as String,
        rawStatus: json['raw_status'] as String? ?? json['status'] as String? ?? 'PENDING',
        status: json['status'] as String,
        price: (json['price'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
      );
}
