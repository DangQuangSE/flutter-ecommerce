import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/shop_directions_launcher.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_info_row.dart';

/// A tappable row — same tier as the address/phone/opening-hours rows —
/// that hands off to Google Maps for directions. Resolves the store's
/// coordinate on tap (geocoding the address if no lat/lng is saved) rather
/// than eagerly, since this row may never be tapped.
class ShopDirectionsRow extends StatefulWidget {
  final ShopEntity shop;

  const ShopDirectionsRow({super.key, required this.shop});

  @override
  State<ShopDirectionsRow> createState() => _ShopDirectionsRowState();
}

class _ShopDirectionsRowState extends State<ShopDirectionsRow> {
  bool _busy = false;

  Future<void> _onTap() async {
    if (_busy) return;
    setState(() => _busy = true);

    final point =
        await resolveShopPoint(widget.shop, context.read<DirectionsCubit>());
    if (!mounted) return;
    if (point == null) {
      setState(() => _busy = false);
      _showSnack(AppStrings.shopMapUnavailable);
      return;
    }

    final launched = await launchDirectionsTo(point, placeId: widget.shop.placeId);
    if (!mounted) return;
    setState(() => _busy = false);
    if (!launched) _showSnack(AppStrings.shopMapOpenError);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShopInfoRow(
      icon: Icons.directions_rounded,
      text: AppStrings.shopGetDirections,
      trailing: _busy
          ? const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
      onTap: _busy ? null : _onTap,
    );
  }
}
