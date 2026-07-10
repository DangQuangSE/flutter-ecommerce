import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/features/geo/data/datasources/directions_remote_datasource.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';

/// A canned polyline5-encoded string (the polyline algorithm's own doc example)
/// that decodes to three known points, so we assert the datasource actually
/// decodes OSRM's `geometry` — not just passes bytes through.
const _encodedPolyline = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';

const _validOsrmJson = {
  'code': 'Ok',
  'routes': [
    {
      'geometry': _encodedPolyline,
      'distance': 5200.0, // metres
      'duration': 720.0, // seconds
    },
  ],
};

/// A fake Dio HTTP adapter that returns a canned response without touching the
/// network — used to exercise [DirectionsRemoteDataSourceImpl] via its injected
/// `Dio` constructor argument.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._respond);

  final ResponseBody Function(RequestOptions options) _respond;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _respond(options);
  }

  @override
  void close({bool force = false}) {}
}

Dio _dioReturning(
  Object body, {
  void Function(RequestOptions options)? onRequest,
}) {
  final dio = Dio();
  dio.httpClientAdapter = _FakeHttpClientAdapter((options) {
    onRequest?.call(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  });
  return dio;
}

const _origin = GeoPoint(latitude: 10.0, longitude: 106.0);
const _destination = GeoPoint(latitude: 10.1, longitude: 106.1);

void main() {
  group('DirectionsRemoteDataSourceImpl.getDrivingRoute', () {
    test('maps a valid OSRM response to a RoutePreview', () async {
      final dataSource = DirectionsRemoteDataSourceImpl(
        dio: _dioReturning(_validOsrmJson),
      );

      final route = await dataSource.getDrivingRoute(
        origin: _origin,
        destination: _destination,
      );

      // 5200 m → "5.2 km", 720 s → "12 phút" (formatted by the datasource).
      expect(route.distanceText, '5.2 km');
      expect(route.durationText, '12 phút');
      expect(route.distanceMeters, 5200);
      expect(route.durationSeconds, 720);
      expect(route.polyline, hasLength(3));
      expect(route.polyline.first.latitude, closeTo(38.5, 0.001));
      expect(route.polyline.first.longitude, closeTo(-120.2, 0.001));
    });

    test('sends coordinates in OSRM lon,lat;lon,lat path order', () async {
      late String capturedPath;
      final dataSource = DirectionsRemoteDataSourceImpl(
        dio: _dioReturning(
          _validOsrmJson,
          onRequest: (options) => capturedPath = options.path,
        ),
      );

      await dataSource.getDrivingRoute(
        origin: _origin,
        destination: _destination,
      );

      // OSRM uses lon,lat — origin 10.0,106.0 → "106.0,10.0".
      expect(capturedPath, contains('106.0,10.0;106.1,10.1'));
    });

    test('a non-Ok code throws a ParseException', () async {
      final dataSource = DirectionsRemoteDataSourceImpl(
        dio: _dioReturning({'code': 'NoRoute', 'routes': <dynamic>[]}),
      );

      expect(
        () => dataSource.getDrivingRoute(
          origin: _origin,
          destination: _destination,
        ),
        throwsA(isA<ParseException>()),
      );
    });
  });
}
