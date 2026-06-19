import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final int? id;
  final String name;
  final String? address;
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
    this.rating,
    this.ratingCount = 0,
    this.phone,
    this.openingHours,
    this.description,
    this.logoUrl,
    this.coverUrl,
  });

  ShopEntity copyWith({
    int? id,
    String? name,
    String? address,
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
        rating,
        ratingCount,
        phone,
        openingHours,
        description,
        logoUrl,
        coverUrl,
      ];
}
