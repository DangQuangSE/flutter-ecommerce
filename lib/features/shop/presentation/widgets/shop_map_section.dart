import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/maps_url_builder.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/widgets/store_map_view.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_directions_fab.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_placeholder.dart';

/// The real (OpenStreetMap) map at the top of the customer store screen: shows
/// the store marker and, on tap of "Chỉ đường", hands off straight to the
/// Google Maps app for turn-by-turn directions (no in-app route preview).
/// Resolves the store coordinate from the saved lat/lng, falling back to
/// geocoding the address.
class ShopMapSection extends StatefulWidget {
  final ShopEntity shop;

  const ShopMapSection({super.key, required this.shop});

  @override
  State<ShopMapSection> createState() => _ShopMapSectionState();
}

class _ShopMapSectionState extends State<ShopMapSection> {
  static const double _mapHeight = 260;

  GeoPoint? _storePoint;
  bool _resolving = true;
  bool _launchingDirections = false;

  @override
  void initState() {
    super.initState();
    _resolveStorePoint();
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

  Future<void> _onGetDirections() async {
    final point = _storePoint;
    if (point == null || _launchingDirections) return;

    setState(() => _launchingDirections = true);
    // No origin: Google Maps fills it in from the device's current location.
    final uri = buildGoogleMapsDirectionsUri(
      destination: point,
      destinationPlaceId: widget.shop.placeId,
    );
    bool launched;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (!mounted) return;
    setState(() => _launchingDirections = false);
    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.shopMapOpenError),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      child: Stack(
        children: [
          Positioned.fill(
            child: StoreMapView(center: point, storeMarker: point),
          ),
          Positioned(
            right: AppSizes.paddingMd,
            bottom: AppSizes.paddingMd,
            child: ShopMapDirectionsFab(
              loading: _launchingDirections,
              onPressed: _onGetDirections,
            ),
          ),
        ],
      ),
    );
  }
}
