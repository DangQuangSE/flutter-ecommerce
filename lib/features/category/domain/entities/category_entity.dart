import 'package:equatable/equatable.dart';

/// A product category managed in the admin area.
///
/// Maps to the backend `CategoryResponse` / `CategoryRequest`. The backend
/// serialises booleans as `active` / `customizable` in responses but expects
/// `isActive` / `isCustomizable` in requests — handled in CategoryModel.
class CategoryEntity extends Equatable {
  final int? id;
  final String name;
  final String? slug;
  final String? description;
  final int? parentId;
  final String? imageUrl;
  final int? displayOrder;
  final bool isActive;
  final bool isCustomizable;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    this.id,
    required this.name,
    this.slug,
    this.description,
    this.parentId,
    this.imageUrl,
    this.displayOrder,
    this.isActive = true,
    this.isCustomizable = false,
    this.createdAt,
    this.updatedAt,
  });

  CategoryEntity copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    int? parentId,
    String? imageUrl,
    int? displayOrder,
    bool? isActive,
    bool? isCustomizable,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      isCustomizable: isCustomizable ?? this.isCustomizable,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        slug,
        description,
        parentId,
        imageUrl,
        displayOrder,
        isActive,
        isCustomizable,
        createdAt,
        updatedAt,
      ];
}
