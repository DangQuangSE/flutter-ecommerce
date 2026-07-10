import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/maps_url_builder.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_state.dart';
import 'package:flutter_ecommerce/features/geo/presentation/widgets/directions_bottom_card.dart';
import 'package:flutter_ecommerce/features/geo/presentation/widgets/store_map_view.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_directions_fab.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_placeholder.dart';

/// The real (OpenStreetMap) map at the top of the customer store screen: shows
/// the store marker and, once the user taps "Chỉ đường", a route preview
/// (polyline + ETA) with a hand-off to the Google Maps app. Resolves the store
/// coordinate from the saved lat/lng, falling back to geocoding the address (R5).
class ShopMapSection extends StatefulWidget {
  final ShopEntity shop;

  const ShopMapSection({super.key, required this.shop});

  @override
  State<ShopMapSection> createState() => _ShopMapSectionState();
}

class _ShopMapSectionState extends State<ShopMapSection> {
  static const double _mapHeight = 260;
  static const double _boundsPadding = 48;

  final MapController _mapController = MapController();
  GeoPoint? _storePoint;
  bool _resolving = true;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _resolveStorePoint();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _resolveStorePoint() async {
    final shop = widget.shop;
    if (shop.hasCoordinates) {
      setState(() {
        _storePoint =
            GeoPoint(latitude: shop.latitude!, longitude: shop.longitude!);
        _resolving = false;
      });
      return;
    }
    final address = shop.address;
    final resolved = (address == null || address.isEmpty)
        ? null
        : await context.read<DirectionsCubit>().geocodeStoreAddress(address);
    if (!mounted) return;
    setState(() {
      _storePoint = resolved;
      _resolving = false;
    });
  }

  void _onGetDirections() {
    final point = _storePoint;
    if (point == null) return;
    context.read<DirectionsCubit>().loadRoute(destination: point);
  }

  Future<void> _startNavigation(GeoPoint origin) async {
    final point = _storePoint;
    if (point == null) return;
    final uri = buildGoogleMapsDirectionsUri(
      destination: point,
      origin: origin,
      destinationPlaceId: widget.shop.placeId,
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.shopMapOpenError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onDirectionsStateChanged(BuildContext context, DirectionsState state) {
    if (state is DirectionsLoaded) {
      _fitRouteBounds(state.origin, _storePoint!);
    } else if (state is DirectionsError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          behavior: SnackBarBehavior.floating,
          action: state.permanentlyDenied
              ? SnackBarAction(
                  label: AppStrings.shopLocationSettingsLabel,
                  onPressed: () =>
                      context.read<DirectionsCubit>().openLocationSettings(),
                )
              : null,
        ),
      );
    }
  }

  void _fitRouteBounds(GeoPoint a, GeoPoint b) {
    if (!_mapReady) return;
    final bounds = LatLngBounds.fromPoints([
      LatLng(a.latitude, a.longitude),
      LatLng(b.latitude, b.longitude),
    ]);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(_boundsPadding),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_resolving) {
      return const SizedBox(
        height: _mapHeight,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }
    final point = _storePoint;
    if (point == null) {
      return const ShopMapPlaceholder(height: _mapHeight);
    }
    return SizedBox(
      height: _mapHeight,
      child: BlocConsumer<DirectionsCubit, DirectionsState>(
        listener: _onDirectionsStateChanged,
        builder: (context, state) => _buildMapStack(context, point, state),
      ),
    );
  }

  Widget _buildMapStack(
    BuildContext context,
    GeoPoint storePoint,
    DirectionsState state,
  ) {
    final loaded = state is DirectionsLoaded ? state : null;
    return Stack(
      children: [
        Positioned.fill(
          child: StoreMapView(
            center: storePoint,
            storeMarker: storePoint,
            userMarker: loaded?.origin,
            routePolyline: loaded?.route.polyline ?? const [],
            controller: _mapController,
            onMapReady: () => _mapReady = true,
          ),
        ),
        if (loaded != null)
          Positioned(
            left: AppSizes.paddingMd,
            right: AppSizes.paddingMd,
            bottom: AppSizes.paddingMd,
            child: DirectionsBottomCard(
              route: loaded.route,
              onStart: () => _startNavigation(loaded.origin),
              onClose: () => context.read<DirectionsCubit>().reset(),
            ),
          )
        else
          Positioned(
            right: AppSizes.paddingMd,
            bottom: AppSizes.paddingMd,
            child: ShopMapDirectionsFab(
              loading: state is DirectionsLoading,
              onPressed: _onGetDirections,
            ),
          ),
      ],
    );
  }
}
