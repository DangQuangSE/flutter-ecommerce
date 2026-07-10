import 'package:equatable/equatable.dart';

/// A latitude/longitude pair, decoupled from any map SDK type so the domain
/// layer never imports `flutter_map`/`latlong2`.
class GeoPoint extends Equatable {
  final double latitude;
  final double longitude;

  const GeoPoint({required this.latitude, required this.longitude});

  @override
  List<Object?> get props => [latitude, longitude];
}
