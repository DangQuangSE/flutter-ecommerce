import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String imageUrl;

  const CartItemEntity({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get subtotal => price * quantity;

  CartItemEntity copyWith({int? quantity}) => CartItemEntity(
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity ?? this.quantity,
        imageUrl: imageUrl,
      );

  @override
  List<Object?> get props => [productId, productName, price, quantity, imageUrl];
}
