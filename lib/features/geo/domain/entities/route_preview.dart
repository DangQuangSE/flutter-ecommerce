import 'package:equatable/equatable.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';

/// A single driving route between two points: the decoded path plus
/// human-readable distance/duration used by the Grab/Be-style preview card.
class RoutePreview extends Equatable {
  final List<GeoPoint> polyline;
  final String distanceText;
  final String durationText;
  final int distanceMeters;
  final int durationSeconds;

  const RoutePreview({
    required this.polyline,
    required this.distanceText,
    required this.durationText,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  @override
  List<Object?> get props =>
      [polyline, distanceText, durationText, distanceMeters, durationSeconds];
}
