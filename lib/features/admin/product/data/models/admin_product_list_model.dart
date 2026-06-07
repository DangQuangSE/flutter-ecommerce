import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_list_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class AdminProductListModel {
  final int id;
  final String name;
  final String slug;
  final String? thumbnailUrl;
  final String brandName;
  final String categoryName;
  final double minPrice;
  final double maxPrice;
  final int totalStock;
  final String status;
  final bool isFeatured;

  const AdminProductListModel({
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

  factory AdminProductListModel.fromJson(Map<String, dynamic> json) {
    return AdminProductListModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      brandName: json['brandName'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      minPrice: (json['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['maxPrice'] as num?)?.toDouble() ?? 0.0,
      totalStock: (json['totalStock'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'ACTIVE',
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  AdminProductListEntity toEntity() => AdminProductListEntity(
        id: id,
        name: name,
        slug: slug,
        thumbnailUrl: thumbnailUrl,
        brandName: brandName,
        categoryName: categoryName,
        minPrice: minPrice,
        maxPrice: maxPrice,
        totalStock: totalStock,
        status: ProductStatus.fromJson(status),
        isFeatured: isFeatured,
      );
}
