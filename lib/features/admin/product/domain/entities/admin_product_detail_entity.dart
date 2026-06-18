import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_image_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/entities/product_variant_entity.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class AdminProductDetailEntity extends Equatable {
  final int id;
  final String name;
  final String slug;
  final String? description;
  final int brandId;
  final String brandName;
  final int categoryId;
  final String categoryName;
  final Gender gender;
  final ProductStatus status;
  final bool isFeatured;
  final List<ProductVariantEntity> variants;
  final List<ProductImageEntity> images;
  final int? sizeGroupId;
  final int? couponId;
  final String? couponCode;

  const AdminProductDetailEntity({
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
    required this.variants,
    required this.images,
    this.sizeGroupId,
    this.couponId,
    this.couponCode,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        brandId,
        brandName,
        categoryId,
        categoryName,
        gender,
        status,
        isFeatured,
        variants,
        images,
        sizeGroupId,
        couponId,
        couponCode,
      ];
}
