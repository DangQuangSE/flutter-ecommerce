import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({
    super.id,
    required super.name,
    super.slug,
    super.description,
    super.parentId,
    super.imageUrl,
    super.displayOrder,
    super.isActive,
    super.isCustomizable,
    super.createdAt,
    super.updatedAt,
  });

  /// Parses a backend `CategoryResponse`. Booleans arrive as `active` /
  /// `customizable` (Jackson getter naming), not `isActive` / `isCustomizable`.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['description'] as String?,
      parentId: (json['parentId'] as num?)?.toInt(),
      imageUrl: json['imageUrl'] as String?,
      displayOrder: (json['displayOrder'] as num?)?.toInt(),
      isActive: json['active'] as bool? ?? json['isActive'] as bool? ?? true,
      isCustomizable: json['customizable'] as bool? ??
          json['isCustomizable'] as bool? ??
          false,
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  /// Builds a `CategoryRequest` body for create/update. Only `name` is required;
  /// nulls are omitted so the backend keeps its defaults.
  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (parentId != null) 'parentId': parentId,
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
      if (displayOrder != null) 'displayOrder': displayOrder,
      'isActive': isActive,
      'isCustomizable': isCustomizable,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity e) => CategoryModel(
        id: e.id,
        name: e.name,
        slug: e.slug,
        description: e.description,
        parentId: e.parentId,
        imageUrl: e.imageUrl,
        displayOrder: e.displayOrder,
        isActive: e.isActive,
        isCustomizable: e.isCustomizable,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  static DateTime? _parseDate(dynamic value) =>
      value is String ? DateTime.tryParse(value) : null;
}
