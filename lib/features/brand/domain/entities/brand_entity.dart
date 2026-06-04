import 'package:equatable/equatable.dart';

class BrandEntity extends Equatable {
  final int? id;
  final String name;
  final String slug;
  final String description;
  final String logoUrl;
  final String country;
  final String websiteUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BrandEntity({
    this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.logoUrl,
    required this.country,
    required this.websiteUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  BrandEntity copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? logoUrl,
    String? country,
    String? websiteUrl,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BrandEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      country: country ?? this.country,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      isActive: isActive ?? this.isActive,
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
        logoUrl,
        country,
        websiteUrl,
        isActive,
        createdAt,
        updatedAt,
      ];
}
