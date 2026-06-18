import 'package:flutter_ecommerce/features/admin/product/data/models/product_image_model.dart';
import 'package:flutter_ecommerce/features/admin/product/data/models/product_variant_model.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/admin_product_detail_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class AdminProductDetailModel {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int brandId;
  final String brandName;
  final int categoryId;
  final String categoryName;
  final String gender;
  final String status;
  final bool isFeatured;
  final List<ProductImageModel> images;
  final List<ProductVariantModel> variants;
  final int? sizeGroupId;

  const AdminProductDetailModel({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    required this.brandId,
    required this.brandName,
    required this.categoryId,
    required this.categoryName,
    required this.gender,
    required this.status,
    required this.isFeatured,
    required this.images,
    required this.variants,
    this.sizeGroupId,
  });

  factory AdminProductDetailModel.fromJson(Map<String, dynamic> json) {
    return AdminProductDetailModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      brandId: (json['brandId'] as num?)?.toInt() ?? 0,
      brandName: json['brandName'] as String? ?? '',
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName'] as String? ?? '',
      gender: json['gender'] as String? ?? 'UNISEX',
      status: json['status'] as String? ?? 'ACTIVE',
      isFeatured: json['isFeatured'] as bool? ?? false,
      sizeGroupId: (json['sizeGroupId'] as num?)?.toInt(),
      images: (json['images'] as List?)
              ?.map(
                  (e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      variants: (json['variants'] as List?)
              ?.map((e) =>
                  ProductVariantModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  AdminProductDetailEntity toEntity() => AdminProductDetailEntity(
        id: id,
        name: name,
        slug: slug,
        description: description,
        brandId: brandId,
        brandName: brandName,
        categoryId: categoryId,
        categoryName: categoryName,
        gender: Gender.fromJson(gender),
        status: ProductStatus.fromJson(status),
        isFeatured: isFeatured,
        variants: variants.map((v) => v.toEntity()).toList(),
        images: images.map((i) => i.toEntity()).toList(),
        sizeGroupId: sizeGroupId,
      );
}
