import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';

/// The resolved coordinate + formatted address for a picked/typed place.
/// Returned by geocoding and Place Details so the admin picker can drop a pin
/// and persist a clean address in one step.
class GeocodedPlace extends Equatable {
  final GeoPoint point;
  final String formattedAddress;

  const GeocodedPlace({required this.point, required this.formattedAddress});

  @override
  List<Object?> get props => [point, formattedAddress];
}
