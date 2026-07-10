import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/route_preview.dart';

abstract interface class DirectionsRepository {
  Future<Result<RoutePreview>> getDrivingRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  });
}
