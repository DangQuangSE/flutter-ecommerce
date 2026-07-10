import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/data/datasources/places_remote_datasource.dart';
import 'package:flutter_ecommerce/features/geo/data/repositories/geo_guard.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geocoded_place.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  final PlacesRemoteDataSource _remoteDataSource;

  const PlacesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<List<PlaceSuggestion>>> autocomplete(String query) {
    return geoGuard(() => _remoteDataSource.autocomplete(query));
  }

  @override
  Future<Result<GeocodedPlace>> geocodeAddress(String address) {
    return geoGuard(() => _remoteDataSource.geocodeAddress(address));
  }

  @override
  Future<Result<GeocodedPlace>> reverseGeocode(GeoPoint point) {
    return geoGuard(() => _remoteDataSource.reverseGeocode(point));
  }
}
