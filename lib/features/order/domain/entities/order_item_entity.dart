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
  final int? customDesignId;
  final String? designImageUrl;
  final double printingPrice;

  const OrderItemEntity({
    required this.id,
    required this.productName,
    required this.size,
    required this.color,
    required this.quantity,
    required this.price,
    this.imageUrl,
    this.isReviewed = false,
    this.customDesignId,
    this.designImageUrl,
    this.printingPrice = 0,
  });

  double get lineTotal => price * quantity;
  bool get hasCustomPrinting => customDesignId != null;
  double get printingLineTotal => printingPrice * quantity;

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
        customDesignId,
        designImageUrl,
        printingPrice,
      ];
}
