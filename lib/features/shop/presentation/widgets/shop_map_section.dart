import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/widgets/store_map_view.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/shop_directions_launcher.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_directions_fab.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_placeholder.dart';

/// The real (OpenStreetMap) map at the top of the customer store screen —
/// it IS the header (the shop logo overlaps its bottom-left corner, replacing
/// what used to be a plain cover photo, see `ShopCoverHeader`) — shows the
/// store marker and, on tap of "Chỉ đường", hands off straight to the Google
/// Maps app for turn-by-turn directions (no in-app route preview). Resolves
/// the store coordinate from the saved lat/lng, falling back to geocoding
/// the address.
class ShopMapSection extends StatefulWidget {
  final ShopEntity shop;
  final double height;

  const ShopMapSection({super.key, required this.shop, required this.height});

  @override
  State<ShopMapSection> createState() => _ShopMapSectionState();
}

class _ShopMapSectionState extends State<ShopMapSection> {
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
    // Resolved synchronously (no await) when possible, so the marker never
    // flashes a loading spinner for the common already-has-coordinates case.
    if (shop.hasCoordinates) {
      setState(() {
        _storePoint =
            GeoPoint(latitude: shop.latitude!, longitude: shop.longitude!);
        _resolving = false;
      });
      return;
    }
    final resolved = await resolveShopPoint(shop, context.read<DirectionsCubit>());
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
    final launched =
        await launchDirectionsTo(point, placeId: widget.shop.placeId);
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
      return SizedBox(
        height: widget.height,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }
    final point = _storePoint;
    if (point == null) {
      return ShopMapPlaceholder(height: widget.height);
    }
    return SizedBox(
      height: widget.height,
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
