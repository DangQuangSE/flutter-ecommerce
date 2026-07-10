import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/maps_url_builder.dart';

const _destination = GeoPoint(latitude: 10.7769, longitude: 106.7009);

void main() {
  group('buildGoogleMapsDirectionsUri', () {
    test('host, path, and the always-present query params', () {
      final uri = buildGoogleMapsDirectionsUri(destination: _destination);

      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['api'], '1');
      expect(uri.queryParameters['travelmode'], 'driving');
      expect(uri.queryParameters['destination'], '10.7769,106.7009');
    });

    test('omits origin when not provided', () {
      final uri = buildGoogleMapsDirectionsUri(destination: _destination);

      expect(uri.queryParameters.containsKey('origin'), isFalse);
    });

    test('includes origin when provided', () {
      const origin = GeoPoint(latitude: 21.0285, longitude: 105.8542);

      final uri = buildGoogleMapsDirectionsUri(
        destination: _destination,
        origin: origin,
      );

      expect(uri.queryParameters['origin'], '21.0285,105.8542');
    });

    test('omits destination_place_id when null', () {
      final uri = buildGoogleMapsDirectionsUri(destination: _destination);

      expect(uri.queryParameters.containsKey('destination_place_id'), isFalse);
    });

    test('omits destination_place_id when an empty string', () {
      final uri = buildGoogleMapsDirectionsUri(
        destination: _destination,
        destinationPlaceId: '',
      );

      expect(uri.queryParameters.containsKey('destination_place_id'), isFalse);
    });

    test('includes destination_place_id when non-empty', () {
      final uri = buildGoogleMapsDirectionsUri(
        destination: _destination,
        destinationPlaceId: 'ChIJ123abc',
      );

      expect(uri.queryParameters['destination_place_id'], 'ChIJ123abc');
    });
  });
}
