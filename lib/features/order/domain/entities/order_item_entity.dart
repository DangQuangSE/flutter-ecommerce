import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int id;
  final String productName;
  final String size;
  final String color;
  final int quantity;
  final double price;
  final String? imageUrl;
  final bool isReviewed;

  const OrderItemEntity({
    required this.id,
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.isReviewed = false,
  });

  double get lineTotal => price * quantity;

  @override
  List<Object?> get props => [
        id,
        productName,
        size,
        color,
        quantity,
        price,
        imageUrl,
        isReviewed,
      ];
}
