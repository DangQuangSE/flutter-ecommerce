import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/gender.dart';
import 'package:flutter_ecommerce/features/admin/product/domain/enums/product_status.dart';

class CreateProductParams extends Equatable {
  final String name;
  final String? description;
  final int categoryId;
  final int brandId;
  final Gender gender;
  final bool isFeatured;
  final ProductStatus status;
  final int? sizeGroupId;

  const CreateProductParams({
    required this.name,
    this.description,
    required this.categoryId,
    required this.brandId,
    required this.gender,
    required this.isFeatured,
    required this.status,
    this.sizeGroupId,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        categoryId,
        brandId,
        gender,
        isFeatured,
        status,
        sizeGroupId,
      ];
}
