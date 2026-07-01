import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';

class CatalogToolbar extends StatefulWidget {
  final bool hasActiveFilter;
  final VoidCallback onFilterTap;

  const CatalogToolbar({
    super.key,
    required this.hasActiveFilter,
    required this.onFilterTap,
  });

  @override
  State<CatalogToolbar> createState() => _CatalogToolbarState();
}

class _CatalogToolbarState extends State<CatalogToolbar> {
  static const _searchDebounceDuration = Duration(milliseconds: 500);

  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(_searchDebounceDuration, () {
      if (!mounted) return;
      context.read<ProductCatalogBloc>().add(
            ProductCatalogFilterChanged(
              keyword: value.isEmpty ? null : value,
              clearKeyword: value.isEmpty,
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: AppSizes.paddingSm,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SearchField(
            controller: _searchController,
            onChanged: _onSearchChanged,
          ),
          AppSizes.spacingSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FilterButton(
                hasActiveFilter: widget.hasActiveFilter,
                onTap: widget.onFilterTap,
              ),
              const _SortDropdown(),
            ],
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: AppStrings.productSearchHint,
        hintStyle: const TextStyle(
          fontSize: AppSizes.fontLg,
          color: AppColors.textHint,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: AppSizes.fontXxl),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          vertical: AppSizes.radiusMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool hasActiveFilter;
  final VoidCallback onTap;

  const _FilterButton({
    required this.hasActiveFilter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.tune_rounded, size: AppSizes.fontXl),
          label: const Text(AppStrings.productFilterTitle),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.divider),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMd,
              vertical: AppSizes.paddingSm,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            ),
          ),
        ),
        if (hasActiveFilter)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              width: AppSizes.radiusMd,
              height: AppSizes.radiusMd,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
      buildWhen: (previous, current) {
        if (previous is ProductCatalogLoaded &&
            current is ProductCatalogLoaded) {
          return previous.sort != current.sort;
        }
        return false;
      },
      builder: (context, state) {
        final currentSort =
            state is ProductCatalogLoaded ? state.sort : 'id,desc';

        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: currentSort,
            style: const TextStyle(
              fontSize: AppSizes.forgotPasswordFontSize,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            items: const [
              DropdownMenuItem(
                value: 'id,desc',
                child: Text(AppStrings.productSortNewest),
              ),
              DropdownMenuItem(
                value: 'salePrice,asc',
                child: Text(AppStrings.productSortPriceAsc),
              ),
              DropdownMenuItem(
                value: 'salePrice,desc',
                child: Text(AppStrings.productSortPriceDesc),
              ),
            ],
            onChanged: (sort) {
              if (sort == null) return;
              context
                  .read<ProductCatalogBloc>()
                  .add(ProductCatalogFilterChanged(sort: sort));
            },
          ),
        );
      },
    );
  }
}
