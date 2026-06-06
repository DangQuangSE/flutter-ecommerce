import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';

class BrandModel extends BrandEntity {
  const BrandModel({
    super.id,
    required super.name,
    required super.slug,
    required super.description,
    required super.logoUrl,
    required super.country,
    required super.websiteUrl,
    required super.isActive,
    super.createdAt,
    super.updatedAt,
  });

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      logoUrl: json['logoUrl'] as String? ?? '',
      country: json['country'] as String? ?? '',
      websiteUrl: json['websiteUrl'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? json['active'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'logoUrl': logoUrl,
      'country': country,
      'websiteUrl': websiteUrl,
      'isActive': isActive,
    };
  }

  factory BrandModel.fromEntity(BrandEntity entity) {
    return BrandModel(
      id: entity.id,
      name: entity.name,
      slug: entity.slug,
      description: entity.description,
      logoUrl: entity.logoUrl,
      country: entity.country,
      websiteUrl: entity.websiteUrl,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
