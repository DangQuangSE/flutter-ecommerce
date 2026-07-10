import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/data/datasources/directions_remote_datasource.dart';
import 'package:flutter_ecommerce/features/geo/data/repositories/geo_guard.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/route_preview.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/directions_repository.dart';

class DirectionsRepositoryImpl implements DirectionsRepository {
  final DirectionsRemoteDataSource _remoteDataSource;

  const DirectionsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<RoutePreview>> getDrivingRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  }) {
    return geoGuard(
      () => _remoteDataSource.getDrivingRoute(
        origin: origin,
        destination: destination,
      ),
    );
  }
}
