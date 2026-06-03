import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class UpdateProductParams extends Equatable {
  final String name;
  final String? description;
  final int categoryId;
  final int brandId;
  final Gender gender;
  final ProductStatus status;
  final bool isFeatured;

  const UpdateProductParams({
    required this.name,
    this.description,
    required this.categoryId,
    required this.brandId,
    required this.gender,
    required this.status,
    required this.isFeatured,
  });

  @override
  List<Object?> get props =>
      [name, description, categoryId, brandId, gender, status, isFeatured];
}
