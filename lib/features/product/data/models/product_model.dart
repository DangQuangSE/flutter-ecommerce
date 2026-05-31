import 'package:flutter_ecommerce/features/product/domain/entities/product_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    required super.imageUrl,
    required super.categoryId,
    required super.stockQuantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      stockQuantity: json['stock_quantity'] as int? ?? 0,
    );
  }

  static List<ProductModel> get mockList => [
        const ProductModel(
          id: 'p-001',
          name: 'Wireless Headphones',
          description: 'Premium noise-cancelling headphones',
          price: 149.99,
          imageUrl: 'https://via.placeholder.com/300',
          categoryId: 'cat-electronics',
          stockQuantity: 50,
        ),
        const ProductModel(
          id: 'p-002',
          name: 'Running Shoes',
          description: 'Lightweight performance shoes',
          price: 89.99,
          imageUrl: 'https://via.placeholder.com/300',
          categoryId: 'cat-sports',
          stockQuantity: 120,
        ),
      ];
}
