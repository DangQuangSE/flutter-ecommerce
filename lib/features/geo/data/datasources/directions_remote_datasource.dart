import 'package:dio/dio.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/route_preview.dart';

/// Computes a driving route via **OSRM** (public OpenStreetMap routing server) —
/// free, no API key. Returns the decoded polyline plus a human-readable
/// distance/ETA for the Grab/Be-style preview card. OSRM uses `lon,lat` order.
abstract interface class DirectionsRemoteDataSource {
  Future<RoutePreview> getDrivingRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  });
}

class DirectionsRemoteDataSourceImpl implements DirectionsRemoteDataSource {
  final Dio _dio;
  final PolylinePoints _polylinePoints;

  DirectionsRemoteDataSourceImpl({Dio? dio, PolylinePoints? polylinePoints})
      : _dio = dio ?? Dio(),
        _polylinePoints = polylinePoints ?? PolylinePoints();

  static const String _baseUrl =
      'https://router.project-osrm.org/route/v1/driving';

  @override
  Future<RoutePreview> getDrivingRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  }) async {
    // OSRM path is `{lon},{lat};{lon},{lat}`.
    final coords = '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_baseUrl/$coords',
        queryParameters: const <String, String>{
          'overview': 'full',
          'geometries': 'polyline',
        },
      );
      return _parseRoute(response.data);
    } on DioException catch (e) {
      throw NetworkException(
        e.message ?? 'Không thể tải chỉ đường',
        statusCode: e.response?.statusCode,
      );
    }
  }

  RoutePreview _parseRoute(Map<String, dynamic>? body) {
    final code = body?['code'] as String?;
    if (code != 'Ok') {
      throw const ParseException('Không tìm thấy tuyến đường tới cửa hàng');
    }
    final routes = body?['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) {
      throw const ParseException('Không tìm thấy tuyến đường tới cửa hàng');
    }
    final route = routes.first as Map<String, dynamic>;
    final encoded = route['geometry'] as String?;
    if (encoded == null || encoded.isEmpty) {
      throw const ParseException('Dữ liệu tuyến đường không hợp lệ');
    }
    final distanceMeters = (route['distance'] as num?)?.toDouble() ?? 0;
    final durationSeconds = (route['duration'] as num?)?.toDouble() ?? 0;
    final points = _polylinePoints
        .decodePolyline(encoded)
        .map((p) => GeoPoint(latitude: p.latitude, longitude: p.longitude))
        .toList();
    return RoutePreview(
      polyline: points,
      distanceText: _formatDistance(distanceMeters),
      durationText: _formatDuration(durationSeconds),
      distanceMeters: distanceMeters.round(),
      durationSeconds: durationSeconds.round(),
    );
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) return '${(meters / 1000).toStringAsFixed(1)} km';
    return '${meters.round()} m';
  }

  String _formatDuration(double seconds) {
    final totalMinutes = (seconds / 60).round();
    if (totalMinutes < 60) return '$totalMinutes phút';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return minutes == 0 ? '$hours giờ' : '$hours giờ $minutes phút';
  }
}
