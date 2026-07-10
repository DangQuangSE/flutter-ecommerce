import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geocoded_place.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';

abstract interface class PlacesRepository {
  /// Address autocomplete/search (Nominatim). Each suggestion already carries
  /// its coordinate, so selecting one needs no further lookup.
  Future<Result<List<PlaceSuggestion>>> autocomplete(String query);

  /// Resolves a free-text address to a coordinate (Nominatim geocoding).
  Future<Result<GeocodedPlace>> geocodeAddress(String address);

  /// Resolves a coordinate to a formatted address (Nominatim reverse geocoding).
  Future<Result<GeocodedPlace>> reverseGeocode(GeoPoint point);
}
