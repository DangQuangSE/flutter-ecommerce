import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_state.dart';

/// Resolves a store coordinate for the customer store screen. Getting
/// directions hands off straight to the Google Maps app (see
/// `ShopMapSection`/`maps_url_builder.dart`), so this cubit only geocodes the
/// store address as a fallback when the shop has no saved lat/lng.
class DirectionsCubit extends Cubit<DirectionsState> {
  final PlacesRepository _placesRepository;

  DirectionsCubit(this._placesRepository) : super(const DirectionsInitial());

  /// Resolves a store coordinate from a plain address (fallback when the shop
  /// row has no lat/lng). Returns `null` if geocoding fails.
  Future<GeoPoint?> geocodeStoreAddress(String address) async {
    if (address.trim().isEmpty) return null;
    final result = await _placesRepository.geocodeAddress(address);
    return switch (result) {
      Success(:final data) => data.point,
      ResultFailure() => null,
    };
  }
}
