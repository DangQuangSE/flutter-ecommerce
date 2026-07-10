import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';

sealed class StoreLocationPickerState extends Equatable {
  const StoreLocationPickerState();

  @override
  List<Object?> get props => [];
}

/// Before the current shop location has been loaded into the picker.
final class StoreLocationPickerInitial extends StoreLocationPickerState {
  const StoreLocationPickerInitial();
}

/// The working state of the picker. [point] is null until the admin selects a
/// suggestion or taps the map; [suggestions] holds live search results.
final class StoreLocationPickerReady extends StoreLocationPickerState {
  final GeoPoint? point;
  final String address;
  final List<PlaceSuggestion> suggestions;
  final bool isSearching;
  final bool isResolvingAddress;

  const StoreLocationPickerReady({
    this.point,
    this.address = '',
    this.suggestions = const [],
    this.isSearching = false,
    this.isResolvingAddress = false,
  });

  bool get canSave => point != null;

  StoreLocationPickerReady copyWith({
    GeoPoint? Function()? point,
    String? address,
    List<PlaceSuggestion>? suggestions,
    bool? isSearching,
    bool? isResolvingAddress,
  }) {
    return StoreLocationPickerReady(
      point: point != null ? point() : this.point,
      address: address ?? this.address,
      suggestions: suggestions ?? this.suggestions,
      isSearching: isSearching ?? this.isSearching,
      isResolvingAddress: isResolvingAddress ?? this.isResolvingAddress,
    );
  }

  @override
  List<Object?> get props =>
      [point, address, suggestions, isSearching, isResolvingAddress];
}

/// A picker-level error (e.g. address search failed).
final class StoreLocationPickerError extends StoreLocationPickerState {
  final String message;

  const StoreLocationPickerError(this.message);

  @override
  List<Object?> get props => [message];
}
