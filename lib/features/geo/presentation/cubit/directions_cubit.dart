import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/data/services/device_location_service.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/directions_repository.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_state.dart';

/// Drives the customer "Chỉ đường" preview: gets the device location, asks the
/// Directions API for a route to the store, and exposes the result for the map
/// + ETA card. Also geocodes the store address as a fallback when the shop has
/// no saved coordinates.
class DirectionsCubit extends Cubit<DirectionsState> {
  final DirectionsRepository _directionsRepository;
  final PlacesRepository _placesRepository;
  final DeviceLocationService _locationService;

  DirectionsCubit(
    this._directionsRepository,
    this._placesRepository,
    this._locationService,
  ) : super(const DirectionsInitial());

  /// Requests the current location then a driving route to [destination].
  Future<void> loadRoute({required GeoPoint destination}) async {
    emit(const DirectionsLoading());

    final locationResult = await _locationService.currentPosition();
    final GeoPoint origin;
    switch (locationResult) {
      case Success(:final data):
        origin = data;
      case ResultFailure(:final failure):
        final permanentlyDenied =
            failure is LocationFailure && failure.permanentlyDenied;
        emit(DirectionsError(failure.message,
            permanentlyDenied: permanentlyDenied));
        return;
    }

    final routeResult = await _directionsRepository.getDrivingRoute(
      origin: origin,
      destination: destination,
    );
    switch (routeResult) {
      case Success(:final data):
        emit(DirectionsLoaded(route: data, origin: origin));
      case ResultFailure(:final failure):
        emit(DirectionsError(failure.message));
    }
  }

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

  /// Clears any active route, returning the map to marker-only.
  void reset() => emit(const DirectionsInitial());

  Future<void> openLocationSettings() => _locationService.openSettings();
}
