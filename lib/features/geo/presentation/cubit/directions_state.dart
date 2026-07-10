import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/route_preview.dart';

sealed class DirectionsState extends Equatable {
  const DirectionsState();

  @override
  List<Object?> get props => [];
}

/// No directions requested yet — the map shows just the store marker.
final class DirectionsInitial extends DirectionsState {
  const DirectionsInitial();
}

/// Acquiring the user's location and/or computing the route.
final class DirectionsLoading extends DirectionsState {
  const DirectionsLoading();
}

/// Route ready: [route] holds the polyline + distance/ETA, [origin] is the
/// user's current position (reused for the "Bắt đầu" hand-off).
final class DirectionsLoaded extends DirectionsState {
  final RoutePreview route;
  final GeoPoint origin;

  const DirectionsLoaded({required this.route, required this.origin});

  @override
  List<Object?> get props => [route, origin];
}

/// Something failed. [permanentlyDenied] is true when location permission was
/// permanently denied, so the UI can offer an "open settings" shortcut.
final class DirectionsError extends DirectionsState {
  final String message;
  final bool permanentlyDenied;

  const DirectionsError(this.message, {this.permanentlyDenied = false});

  @override
  List<Object?> get props => [message, permanentlyDenied];
}
