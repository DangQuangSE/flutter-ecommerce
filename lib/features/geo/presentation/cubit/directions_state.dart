import 'package:equatable/equatable.dart';

sealed class DirectionsState extends Equatable {
  const DirectionsState();

  @override
  List<Object?> get props => [];
}

/// The only state: `DirectionsCubit` only resolves a store address to a
/// coordinate (`geocodeStoreAddress`), which returns its result directly
/// rather than emitting — getting directions hands off straight to the
/// Google Maps app, with no in-app route preview to track state for.
final class DirectionsInitial extends DirectionsState {
  const DirectionsInitial();
}
