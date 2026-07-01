import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_state.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_cover_header.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_error_view.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_info_row.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_rating_row.dart';

class ShopInfoPage extends StatelessWidget {
  const ShopInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppStrings.shopInfoTitle,
          style: GoogleFonts.lexend(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: AppSizes.fontXxl,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
      ),
      body: SafeArea(
        child: BlocBuilder<ShopCubit, ShopState>(
          builder: (context, state) => switch (state) {
            ShopInitial() => Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ShopLoading() => Center(
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ShopLoaded(:final shop) => _ShopContent(shop: shop),
            ShopError(:final message) => ShopErrorView(
                message: message,
                onRetry: () => context.read<ShopCubit>().loadShop(),
              ),
          },
        ),
      ),
    );
  }
}

class _ShopContent extends StatelessWidget {
  final ShopEntity shop;

  const _ShopContent({required this.shop});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShopCoverHeader(shop: shop),
          SizedBox(height: AppSizes.paddingXl + AppSizes.paddingMd),
          _ShopNameSection(shop: shop),
          const Divider(height: AppSizes.paddingXl),
          _ShopDetailsSection(shop: shop),
          AppSizes.spacingLg,
        ],
      ),
    );
  }
}

class _ShopNameSection extends StatelessWidget {
  final ShopEntity shop;

  const _ShopNameSection({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shop.name,
            style: GoogleFonts.lexend(
              fontSize: AppSizes.fontHeading,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          if (shop.rating != null) ...[
            AppSizes.spacingXs,
            ShopRatingRow(
              rating: shop.rating,
              ratingCount: shop.ratingCount,
            ),
          ],
        ],
      ),
    );
  }
}

class _ShopDetailsSection extends StatelessWidget {
  final ShopEntity shop;

  const _ShopDetailsSection({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shop.address != null && shop.address!.isNotEmpty)
            ShopInfoRow(
              icon: Icons.location_on_outlined,
              text: shop.address!,
            ),
          if (shop.phone != null && shop.phone!.isNotEmpty)
            ShopInfoRow(
              icon: Icons.phone_outlined,
              text: shop.phone!,
            ),
          if (shop.openingHours != null && shop.openingHours!.isNotEmpty)
            ShopInfoRow(
              icon: Icons.access_time_rounded,
              text: shop.openingHours!,
            ),
          if (shop.description != null && shop.description!.isNotEmpty) ...[
            AppSizes.spacingMd,
            _ShopDescriptionSection(description: shop.description!),
          ],
        ],
      ),
    );
  }
}

class _ShopDescriptionSection extends StatelessWidget {
  final String description;

  const _ShopDescriptionSection({required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.shopDescriptionLabel,
          style: GoogleFonts.plusJakartaSans(
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: AppSizes.letterSpacingWide,
          ),
        ),
        AppSizes.spacingXs,
        Text(
          description,
          style: TextStyle(
            fontSize: AppSizes.fontLg,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}