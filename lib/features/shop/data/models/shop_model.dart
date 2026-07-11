import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';

class ShopModel extends ShopEntity {
  const ShopModel({
    super.id,
    required super.name,
    super.address,
    super.latitude,
    super.longitude,
    super.placeId,
    super.rating,
    super.ratingCount,
    super.phone,
    super.openingHours,
    super.description,
    super.logoUrl,
    super.coverUrl,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    final rawRating = json['rating'];
    final double? rating = rawRating == null
        ? null
        : rawRating is num
            ? rawRating.toDouble()
            : double.tryParse(rawRating.toString());

    final rawRatingCount = json['ratingCount'];
    final int ratingCount = rawRatingCount == null
        ? 0
        : rawRatingCount is num
            ? rawRatingCount.toInt()
            : int.tryParse(rawRatingCount.toString()) ?? 0;

    return ShopModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String? ?? '',
      address: json['address'] as String?,
      latitude: _toNullableDouble(json['latitude']),
      longitude: _toNullableDouble(json['longitude']),
      placeId: json['placeId'] as String?,
      rating: rating,
      ratingCount: ratingCount,
      phone: json['phone'] as String?,
      openingHours: json['openingHours'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logoUrl'] as String?,
      coverUrl: json['coverUrl'] as String?,
    );
  }

  /// Serialises all non-null fields for the PUT /api/admin/shop request body.
  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (placeId != null) 'placeId': placeId,
      if (rating != null) 'rating': rating,
      'ratingCount': ratingCount,
      if (phone != null) 'phone': phone,
      if (openingHours != null) 'openingHours': openingHours,
      if (description != null) 'description': description,
      if (logoUrl != null) 'logoUrl': logoUrl,
      if (coverUrl != null) 'coverUrl': coverUrl,
    };
  }

  factory ShopModel.fromEntity(ShopEntity entity) {
    return ShopModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      placeId: entity.placeId,
      rating: entity.rating,
      ratingCount: entity.ratingCount,
      phone: entity.phone,
      openingHours: entity.openingHours,
      description: entity.description,
      logoUrl: entity.logoUrl,
      coverUrl: entity.coverUrl,
    );
  }

  ShopEntity toEntity() {
    return ShopEntity(
      id: id,
      name: name,
      address: address,
      latitude: latitude,
      longitude: longitude,
      placeId: placeId,
      rating: rating,
      ratingCount: ratingCount,
      phone: phone,
      openingHours: openingHours,
      description: description,
      logoUrl: logoUrl,
      coverUrl: coverUrl,
    );
  }

  /// Parses a JSON number/string coordinate into a nullable double. The backend
  /// sends lat/lng as `BigDecimal` which may arrive as num or string.
  static double? _toNullableDouble(Object? raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }
}
