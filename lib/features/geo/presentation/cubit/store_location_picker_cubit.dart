import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/store_location_picker_state.dart';

bool _samePoint(GeoPoint? a, GeoPoint? b) =>
    a?.latitude == b?.latitude && a?.longitude == b?.longitude;

/// Drives the admin store-location picker: address search (Nominatim) → drop the
/// pin at the result → tap the map to fine-tune. It only manages *selection* —
/// persistence is done by `ShopCubit.updateShop` so the shop row stays the
/// single source of truth.
class StoreLocationPickerCubit extends Cubit<StoreLocationPickerState> {
  final PlacesRepository _placesRepository;

  StoreLocationPickerCubit(this._placesRepository)
      : super(const StoreLocationPickerInitial());

  StoreLocationPickerReady get _ready => switch (state) {
        StoreLocationPickerReady s => s,
        _ => const StoreLocationPickerReady(),
      };

  /// Seeds the picker with the shop's currently saved location (if any).
  void initialize({GeoPoint? point, String address = ''}) {
    emit(StoreLocationPickerReady(point: point, address: address));
  }

  /// Runs address search for [query]. The caller debounces the text input.
  Future<void> search(String query) async {
    final current = _ready;
    if (query.trim().isEmpty) {
      emit(current.copyWith(suggestions: const [], isSearching: false));
      return;
    }
    emit(current.copyWith(isSearching: true));
    final result = await _placesRepository.autocomplete(query);
    switch (result) {
      case Success(:final data):
        emit(_ready.copyWith(suggestions: data, isSearching: false));
      case ResultFailure(:final failure):
        emit(StoreLocationPickerError(failure.message));
    }
  }

  /// Drops the pin at the picked suggestion (Nominatim supplies the coordinate
  /// inline, so no extra lookup is needed) and clears the suggestion list.
  void selectSuggestion(PlaceSuggestion suggestion) {
    emit(_ready.copyWith(
      point: () => suggestion.point,
      address: suggestion.description,
      suggestions: const [],
      isSearching: false,
    ));
  }

  /// Fine-tunes the coordinate after the admin taps the map, then resolves the
  /// human-readable address for that exact spot so the two never drift apart.
  Future<void> setPoint(GeoPoint point) async {
    emit(_ready.copyWith(point: () => point, isResolvingAddress: true));

    final result = await _placesRepository.reverseGeocode(point);
    // The admin may have tapped again while this lookup was in flight — only
    // apply the resolved address if it still matches the latest pin.
    if (!_samePoint(_ready.point, point)) return;

    switch (result) {
      case Success(:final data):
        emit(_ready.copyWith(
          address: data.formattedAddress,
          isResolvingAddress: false,
        ));
      case ResultFailure():
        // Keep whatever address was already showing; only the coordinate is
        // required to save, so a failed lookup here isn't fatal.
        emit(_ready.copyWith(isResolvingAddress: false));
    }
  }
}
