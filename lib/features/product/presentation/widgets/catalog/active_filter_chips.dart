import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';

class ActiveFilterChips extends StatelessWidget {
  final ProductCatalogLoaded state;
  final VoidCallback onClearAll;

  const ActiveFilterChips({
    super.key,
    required this.state,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final chips = _buildChips(context);
    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.paddingMd,
        vertical: AppSizes.paddingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Wrap(
        spacing: AppSizes.radiusSm,
        runSpacing: AppSizes.radiusSm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton(
            onPressed: onClearAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.paddingSm,
                vertical: AppSizes.paddingXs,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppStrings.productFilterClearAll,
              style: TextStyle(
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
          ),
          ...chips,
        ],
      ),
    );
  }

  List<Widget> _buildChips(BuildContext context) {
    final chips = <Widget>[];

    if (state.categoryName != null) {
      chips.add(_Chip(
        label: state.categoryName!,
        onDelete: () => context.read<ProductCatalogBloc>().add(
              ProductCatalogFilterChanged(clearCategoryId: true, silent: true),
            ),
      ));
    }

    if (state.brandName != null) {
      chips.add(_Chip(
        label: state.brandName!,
        onDelete: () => context.read<ProductCatalogBloc>().add(
              ProductCatalogFilterChanged(clearBrandId: true, silent: true),
            ),
      ));
    }

    if (state.gender != null) {
      chips.add(_Chip(
        label: _genderLabel(state.gender!),
        onDelete: () => context.read<ProductCatalogBloc>().add(
              ProductCatalogFilterChanged(clearGender: true, silent: true),
            ),
      ));
    }

    if (state.productSize != null) {
      chips.add(_Chip(
        label: state.productSize!,
        onDelete: () => context.read<ProductCatalogBloc>().add(
              ProductCatalogFilterChanged(clearProductSize: true, silent: true),
            ),
      ));
    }

    if (state.color != null) {
      chips.add(_Chip(
        label: _capitalize(state.color!),
        onDelete: () => context.read<ProductCatalogBloc>().add(
              ProductCatalogFilterChanged(clearColor: true, silent: true),
            ),
      ));
    }

    if (state.minPrice != null || state.maxPrice != null) {
      chips.add(_Chip(
        label: _priceLabel(state.minPrice, state.maxPrice),
        onDelete: () => context.read<ProductCatalogBloc>().add(
              ProductCatalogFilterChanged(
                clearMinPrice: true,
                clearMaxPrice: true,
                silent: true,
              ),
            ),
      ));
    }

    return chips;
  }

  String _genderLabel(String gender) {
    return switch (gender) {
      'MALE' => AppStrings.productFilterMale,
      'FEMALE' => AppStrings.productFilterFemale,
      'UNISEX' => AppStrings.productFilterUnisex,
      _ => gender,
    };
  }

  String _priceLabel(double? min, double? max) {
    if (min != null && max != null) {
      return AppStrings.productFilterPriceBetween(
        _formatPrice(min),
        _formatPrice(max),
      );
    }
    if (min != null) {
      return AppStrings.productFilterPriceFrom(_formatPrice(min));
    }
    return AppStrings.productFilterPriceTo(_formatPrice(max!));
  }

  String _capitalize(String value) {
    return value.isEmpty
        ? value
        : '${value[0].toUpperCase()}${value.substring(1)}';
  }

  String _formatPrice(double price) {
    final value = price.toInt();
    if (value >= 1000000) {
      final millionValue = value / 1000000;
      final precision = value % 1000000 == 0 ? 0 : 1;
      return '${millionValue.toStringAsFixed(precision)}M';
    }
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return '$value${AppStrings.productFilterCurrencySuffix}';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _Chip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.radiusMd,
        vertical: AppSizes.paddingXs,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppSizes.fontSm,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          AppSizes.spacingXs,
          GestureDetector(
            onTap: onDelete,
            child: const Icon(
              Icons.close,
              size: AppSizes.fontMd,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
