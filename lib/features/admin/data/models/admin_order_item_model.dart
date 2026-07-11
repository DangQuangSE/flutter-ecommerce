import '../../domain/entities/admin_order_item_entity.dart';

class AdminOrderItemModel extends AdminOrderItemEntity {
  const AdminOrderItemModel({
    required super.id,
    required super.productVariantId,
    required super.productName,
    required super.sku,
    required super.size,
    required super.color,
    required super.quantity,
    required super.price,
    super.customDesignId,
    super.designImageUrl,
    super.printingPrice,
  });

  factory AdminOrderItemModel.fromJson(Map<String, dynamic> json) {
    return AdminOrderItemModel(
      id: json['id'] as int,
      productVariantId: json['productVariantId'] as int,
      productName: json['productName'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      size: json['size'] as String? ?? '',
      color: json['color'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      price: (json['price'] as num).toDouble(),
      customDesignId: _parseOptionalInt(json['customDesignId']),
      designImageUrl: json['designImageUrl'] as String?,
      printingPrice: json['printingPrice'] != null
          ? (json['printingPrice'] as num).toDouble()
          : null,
    );
  }

  static int? _parseOptionalInt(Object? value) => switch (value) {
        num number => number.toInt(),
        String text => int.tryParse(text),
        _ => null,
      };
}
