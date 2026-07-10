import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/maps_url_builder.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:url_launcher/url_launcher.dart';

/// Resolves the store's coordinate: uses the saved lat/lng directly, falling
/// back to geocoding the address. Returns `null` if neither is usable.
/// Shared by every entry point that needs "where is the store" (the map
/// marker and the standalone "Chỉ đường" row).
Future<GeoPoint?> resolveShopPoint(
  ShopEntity shop,
  DirectionsCubit directionsCubit,
) async {
  if (shop.hasCoordinates) {
    return GeoPoint(latitude: shop.latitude!, longitude: shop.longitude!);
  }
  final address = shop.address;
  if (address == null || address.isEmpty) return null;
  return directionsCubit.geocodeStoreAddress(address);
}

/// Hands off to the Google Maps app for turn-by-turn directions to [point].
/// No origin is passed: Google Maps fills in the device's current location
/// itself. Returns `false` (never throws) if the app couldn't be launched.
Future<bool> launchDirectionsTo(GeoPoint point, {String? placeId}) async {
  final uri = buildGoogleMapsDirectionsUri(
    destination: point,
    destinationPlaceId: placeId,
  );
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}
