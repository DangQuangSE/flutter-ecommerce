import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_section.dart';

/// The store map doubles as the page header, with the circular logo
/// overlapping its bottom-left corner. The map height scales with the screen
/// width so it stays proportional across phone and tablet sizes.
class ShopCoverHeader extends StatelessWidget {
  final ShopEntity shop;

  const ShopCoverHeader({super.key, required this.shop});

  @override
  Widget build(BuildContext context) {
    final mapHeight = MediaQuery.of(context).size.width * AppSizes.shopCoverRatio;
    return SizedBox(
      height: mapHeight + AppSizes.shopLogoSize / 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ShopMapSection(shop: shop, height: mapHeight),
          Positioned(
            bottom: 0,
            left: AppSizes.paddingMd,
            child: _LogoAvatar(logoUrl: shop.logoUrl, name: shop.name),
          ),
        ],
      ),
    );
  }
}

class _LogoAvatar extends StatelessWidget {
  final String? logoUrl;
  final String name;

  const _LogoAvatar({this.logoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.shopLogoSize,
      height: AppSizes.shopLogoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: AppSizes.borderThick),
        color: AppColors.background,
      ),
      clipBehavior: Clip.antiAlias,
      child: (logoUrl != null && logoUrl!.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: logoUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _fallbackLogo(name),
            )
          : _fallbackLogo(name),
    );
  }

  Widget _fallbackLogo(String name) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: Colors.white,
            fontSize: AppSizes.fontDisplay,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
