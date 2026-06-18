import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class AdminProductListEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? thumbnailUrl;
  final String brandName;
  final String categoryName;
  final double minPrice;
  final double maxPrice;
  final int totalStock;
  final ProductStatus status;
  final bool isFeatured;

  const AdminProductListEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.thumbnailUrl,
    required this.brandName,
    required this.categoryName,
    required this.minPrice,
    required this.maxPrice,
    required this.totalStock,
    required this.status,
    required this.isFeatured,
  });

  AdminProductListEntity copyWith({
    int? id,
    String? name,
    String? slug,
    String? thumbnailUrl,
    String? brandName,
    String? categoryName,
    double? minPrice,
    double? maxPrice,
    int? totalStock,
    ProductStatus? status,
    bool? isFeatured,
  }) {
    return AdminProductListEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      brandName: brandName ?? this.brandName,
      categoryName: categoryName ?? this.categoryName,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      totalStock: totalStock ?? this.totalStock,
      status: status ?? this.status,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        thumbnailUrl,
        brandName,
        categoryName,
        minPrice,
        maxPrice,
        totalStock,
        status,
        isFeatured,
      ];
}
