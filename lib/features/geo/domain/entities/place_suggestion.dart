import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';

/// A place-search prediction (Nominatim/OpenStreetMap). Unlike Google Places,
/// Nominatim returns the coordinate inline with each result, so [point] is
/// carried here and no separate "details" lookup is needed on selection.
class PlaceSuggestion extends Equatable {
  final String description;
  final GeoPoint point;

  const PlaceSuggestion({required this.description, required this.point});

  @override
  List<Object?> get props => [description, point];
}
