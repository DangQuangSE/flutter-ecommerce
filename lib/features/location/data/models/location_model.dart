import 'package:flutter_ecommerce/features/location/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  const LocationModel({required super.code, required super.name});

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        code: json['code'] as int,
        name: json['name'] as String,
      );
}
