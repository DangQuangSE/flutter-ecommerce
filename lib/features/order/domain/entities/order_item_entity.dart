import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int id;
  final String productName;
  final String size;
  final String color;
  final int quantity;
  final double price;
  final String? imageUrl;

  const OrderItemEntity({
    required this.id,
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    this.imageUrl,
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
      ];
}
