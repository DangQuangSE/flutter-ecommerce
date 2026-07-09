import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

/// Circular logo/avatar picker for the admin shop config form.
/// Overlaps the bottom edge of [ShopCoverPicker] via a Positioned parent.
class ShopLogoPicker extends StatelessWidget {
  final String? imageUrl;
  final String shopName;
  final bool isUploading;
  final VoidCallback onTap;

  const ShopLogoPicker({
    super.key,
    this.imageUrl,
    required this.shopName,
    required this.isUploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppStrings.shopLogoPickerLabel,
      button: true,
      child: GestureDetector(
        onTap: isUploading ? null : onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _LogoCircle(imageUrl: imageUrl, shopName: shopName),
            Positioned(
              right: 0,
              bottom: 0,
              child: _CameraBadge(isUploading: isUploading),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoCircle extends StatelessWidget {
  final String? imageUrl;
  final String shopName;

  const _LogoCircle({this.imageUrl, required this.shopName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.shopLogoSize,
      height: AppSizes.shopLogoSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: AppSizes.borderThick),
        color: AppColors.background,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: (imageUrl != null && imageUrl!.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => _InitialFallback(name: shopName),
            )
          : _InitialFallback(name: shopName),
    );
  }
}

class _InitialFallback extends StatelessWidget {
  final String name;

  const _InitialFallback({required this.name});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';
    return Container(
      color: AppColors.primary,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: AppSizes.fontDisplay,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CameraBadge extends StatelessWidget {
  final bool isUploading;

  const _CameraBadge({required this.isUploading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: isUploading
          ? const Padding(
              padding: EdgeInsets.all(4),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
    );
  }
}
