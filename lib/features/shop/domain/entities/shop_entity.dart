import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final int? id;
  final String name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? placeId;
  final double? rating;
  final int ratingCount;
  final String? phone;
  final String? openingHours;
  final String? description;
  final String? logoUrl;
  final String? coverUrl;

  const ShopEntity({
    this.id,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.placeId,
    this.rating,
    this.ratingCount = 0,
    this.phone,
    this.openingHours,
    this.description,
    this.logoUrl,
    this.coverUrl,
  });

  /// True when the shop has a usable map coordinate.
  bool get hasCoordinates => latitude != null && longitude != null;

  ShopEntity copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    // Sentinel wrapper so callers can explicitly CLEAR placeId (e.g. after the
    // admin drags the pin, the old placeId no longer matches the coordinate).
    // `null` = keep current; `() => null` = clear.
    String? Function()? placeId,
    double? rating,
    int? ratingCount,
    String? phone,
    String? openingHours,
    String? description,
    String? logoUrl,
    String? coverUrl,
  }) {
    return ShopEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      placeId: placeId != null ? placeId() : this.placeId,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        placeId,
        rating,
        ratingCount,
        phone,
        openingHours,
        description,
        logoUrl,
        coverUrl,
      ];
}
