import 'package:dio/dio.dart';

import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geocoded_place.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';

/// Address search + geocoding via **Nominatim** (OpenStreetMap) — free, no API
/// key. Used by the admin location picker and the customer's address→coordinate
/// fallback. Nominatim's usage policy requires a valid User-Agent header.
abstract interface class PlacesRemoteDataSource {
  Future<List<PlaceSuggestion>> autocomplete(String query);
  Future<GeocodedPlace> geocodeAddress(String address);
  Future<GeocodedPlace> reverseGeocode(GeoPoint point);
}

class PlacesRemoteDataSourceImpl implements PlacesRemoteDataSource {
  final Dio _dio;

  PlacesRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? Dio();

  static const String _searchUrl =
      'https://nominatim.openstreetmap.org/search';
  static const String _reverseUrl =
      'https://nominatim.openstreetmap.org/reverse';
  static const int _limit = 6;
  // Nominatim policy: identify the app with a valid User-Agent.
  static final Options _options = Options(
    headers: const {'User-Agent': 'flutter_ecommerce_sportpro/1.0'},
  );

  @override
  Future<List<PlaceSuggestion>> autocomplete(String query) async {
    if (query.trim().isEmpty) return const [];
    final results = await _search(query, limit: _limit);
    return results.map(_toSuggestion).toList();
  }

  @override
  Future<GeocodedPlace> geocodeAddress(String address) async {
    final results = await _search(address, limit: 1);
    if (results.isEmpty) {
      throw const ParseException('Không tìm thấy toạ độ cho địa chỉ này');
    }
    return _toGeocoded(results.first);
  }

  @override
  Future<GeocodedPlace> reverseGeocode(GeoPoint point) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _reverseUrl,
        queryParameters: <String, dynamic>{
          'lat': point.latitude,
          'lon': point.longitude,
          'format': 'jsonv2',
        },
        options: _options,
      );
      final json = response.data;
      final address = json?['display_name'] as String?;
      if (address == null || address.isEmpty) {
        throw const ParseException('Không tìm thấy địa chỉ cho vị trí này');
      }
      return GeocodedPlace(point: point, formattedAddress: address);
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Không thể tìm địa chỉ',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _search(
    String query, {
    required int limit,
  }) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        _searchUrl,
        queryParameters: <String, dynamic>{
          'q': query,
          'format': 'jsonv2',
          'addressdetails': 0,
          'countrycodes': 'vn',
          'limit': limit,
        },
        options: _options,
      );
      return (response.data ?? const [])
          .cast<Map<String, dynamic>>()
          .toList();
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Không thể tìm địa chỉ',
        statusCode: e.response?.statusCode,
      );
    }
  }

  PlaceSuggestion _toSuggestion(Map<String, dynamic> json) {
    return PlaceSuggestion(
      description: json['display_name'] as String? ?? '',
      point: _parsePoint(json),
    );
  }

  GeocodedPlace _toGeocoded(Map<String, dynamic> json) {
    return GeocodedPlace(
      point: _parsePoint(json),
      formattedAddress: json['display_name'] as String? ?? '',
    );
  }

  GeoPoint _parsePoint(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '');
    final lon = double.tryParse(json['lon']?.toString() ?? '');
    if (lat == null || lon == null) {
      throw const ParseException('Toạ độ trả về không hợp lệ');
    }
    return GeoPoint(latitude: lat, longitude: lon);
  }
}
