class ProductUpdateRequestModel {
  final String name;
  final String? description;
  final int categoryId;
  final int brandId;
  final String gender;
  final String status;
  final bool isFeatured;
  final int? sizeGroupId;

  const ProductUpdateRequestModel({
    required this.name,
    this.description,
    required this.categoryId,
    required this.brandId,
    required this.gender,
    required this.status,
    required this.isFeatured,
    this.sizeGroupId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'categoryId': categoryId,
        'brandId': brandId,
        'gender': gender,
        'status': status,
        'isFeatured': isFeatured,
        if (sizeGroupId != null) 'sizeGroupId': sizeGroupId,
      };
}
