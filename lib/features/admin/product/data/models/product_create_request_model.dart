class ProductCreateRequestModel {
  final String name;
  final String? description;
  final int categoryId;
  final int brandId;
  final String gender;
  final bool isFeatured;
  final String status;

  const ProductCreateRequestModel({
    required this.name,
    this.description,
    required this.categoryId,
    required this.brandId,
    required this.gender,
    required this.isFeatured,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null) 'description': description,
        'categoryId': categoryId,
        'brandId': brandId,
        'gender': gender,
        'isFeatured': isFeatured,
        'status': status,
      };
}
