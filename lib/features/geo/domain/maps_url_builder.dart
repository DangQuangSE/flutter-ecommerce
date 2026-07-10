import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';

/// Builds the universal Google Maps directions URL used for the "Bắt đầu"
/// hand-off. This link opens the native Google Maps app on Android and iOS when
/// installed, and falls back to the browser otherwise — no scheme whitelisting
/// needed. Prefers [destinationPlaceId] for a precise destination when known.
Uri buildGoogleMapsDirectionsUri({
  required GeoPoint destination,
  GeoPoint? origin,
  String? destinationPlaceId,
}) {
  final params = <String, String>{
    'api': '1',
    'destination': '${destination.latitude},${destination.longitude}',
    'travelmode': 'driving',
  };
  if (origin != null) {
    params['origin'] = '${origin.latitude},${origin.longitude}';
  }
  if (destinationPlaceId != null && destinationPlaceId.isNotEmpty) {
    params['destination_place_id'] = destinationPlaceId;
  }
  return Uri.https('www.google.com', '/maps/dir/', params);
}
