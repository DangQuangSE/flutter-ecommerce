import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';

/// Reusable OpenStreetMap map (via `flutter_map` — no API key / billing). Shows
/// an optional store marker, the user's location, and a route polyline. The
/// admin picker taps the map to move the pin ([onMapTap]); the customer screen
/// passes no tap handler. Kept feature-agnostic so both stay in sync.
///
/// Note (R6): give this a bounded height in a scroll view, otherwise the map
/// swallows the outer scroll gesture.
class StoreMapView extends StatelessWidget {
  final GeoPoint center;
  final GeoPoint? storeMarker;
  final GeoPoint? userMarker;
  final List<GeoPoint> routePolyline;
  final double initialZoom;
  final MapController? controller;
  final VoidCallback? onMapReady;
  final void Function(GeoPoint point)? onMapTap;

  const StoreMapView({
    super.key,
    required this.center,
    this.storeMarker,
    this.userMarker,
    this.routePolyline = const [],
    this.initialZoom = _defaultZoom,
    this.controller,
    this.onMapReady,
    this.onMapTap,
  });

  /// Fallback centre (Hồ Chí Minh City) so the camera target is never null.
  static const GeoPoint fallbackCenter =
      GeoPoint(latitude: 10.7769, longitude: 106.7009);

  static const String _tileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String _userAgent = 'com.example.flutter_ecommerce';
  static const double _defaultZoom = 15;
  static const double _polylineWidth = 5;
  static const double _pinSize = 40;
  static const double _userDotSize = 18;

  static LatLng _toLatLng(GeoPoint p) => LatLng(p.latitude, p.longitude);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCenter: _toLatLng(center),
            initialZoom: initialZoom,
            onMapReady: onMapReady,
            onTap: onMapTap == null
                ? null
                : (_, latLng) => onMapTap!(
                      GeoPoint(
                        latitude: latLng.latitude,
                        longitude: latLng.longitude,
                      ),
                    ),
          ),
          children: [
            TileLayer(urlTemplate: _tileUrl, userAgentPackageName: _userAgent),
            if (routePolyline.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePolyline.map(_toLatLng).toList(),
                    strokeWidth: _polylineWidth,
                    color: AppColors.primary,
                  ),
                ],
              ),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
        const Positioned(
          left: AppSizes.paddingXs,
          bottom: AppSizes.paddingXs,
          child: _OsmAttribution(),
        ),
      ],
    );
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    final user = userMarker;
    if (user != null) {
      markers.add(
        Marker(
          point: _toLatLng(user),
          width: _userDotSize,
          height: _userDotSize,
          child: const _UserDot(),
        ),
      );
    }
    final store = storeMarker;
    if (store != null) {
      markers.add(
        Marker(
          point: _toLatLng(store),
          width: _pinSize,
          height: _pinSize,
          alignment: Alignment.topCenter,
          child: const Icon(
            Icons.location_on,
            color: AppColors.primary,
            size: _pinSize,
          ),
        ),
      );
    }
    return markers;
  }
}

class _UserDot extends StatelessWidget {
  const _UserDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.info,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.white, width: 3),
      ),
    );
  }
}

class _OsmAttribution extends StatelessWidget {
  const _OsmAttribution();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      color: AppColors.white.withValues(alpha: 0.7),
      child: const Text(
        '© OpenStreetMap',
        style: TextStyle(fontSize: AppSizes.fontXs, color: AppColors.black),
      ),
    );
  }
}
