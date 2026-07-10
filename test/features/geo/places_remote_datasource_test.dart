import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/features/geo/data/datasources/places_remote_datasource.dart';

/// Nominatim returns a JSON array; each element carries lat/lon + display_name.
const _nominatimResults = [
  {
    'lat': '10.7769',
    'lon': '106.7009',
    'display_name': 'Chợ Bến Thành, Quận 1, TP.HCM',
  },
  {
    'lat': '10.7295',
    'lon': '106.7215',
    'display_name': 'Nguyễn Văn Linh, Quận 7, TP.HCM',
  },
];

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

void main() {
  group('PlacesRemoteDataSourceImpl (Nominatim)', () {
    test('autocomplete maps results to suggestions with inline coordinates',
        () async {
      final dataSource =
          PlacesRemoteDataSourceImpl(dio: _dioReturning(_nominatimResults));

      final suggestions = await dataSource.autocomplete('cho ben thanh');

      expect(suggestions, hasLength(2));
      expect(suggestions.first.description, 'Chợ Bến Thành, Quận 1, TP.HCM');
      expect(suggestions.first.point.latitude, closeTo(10.7769, 0.0001));
      expect(suggestions.first.point.longitude, closeTo(106.7009, 0.0001));
    });

    test('autocomplete returns [] for a blank query without calling network',
        () async {
      var called = false;
      final dataSource = PlacesRemoteDataSourceImpl(
        dio: _dioReturning(_nominatimResults, onRequest: (_) => called = true),
      );

      final suggestions = await dataSource.autocomplete('   ');

      expect(suggestions, isEmpty);
      expect(called, isFalse);
    });

    test('geocodeAddress resolves the first result to a coordinate', () async {
      final dataSource =
          PlacesRemoteDataSourceImpl(dio: _dioReturning(_nominatimResults));

      final geocoded = await dataSource.geocodeAddress('cho ben thanh');

      expect(geocoded.point.latitude, closeTo(10.7769, 0.0001));
      expect(geocoded.point.longitude, closeTo(106.7009, 0.0001));
      expect(geocoded.formattedAddress, 'Chợ Bến Thành, Quận 1, TP.HCM');
    });

    test('geocodeAddress throws a ParseException on an empty result set',
        () async {
      final dataSource =
          PlacesRemoteDataSourceImpl(dio: _dioReturning(<dynamic>[]));

      expect(
        () => dataSource.geocodeAddress('nowhere'),
        throwsA(isA<ParseException>()),
      );
    });
  });
}
