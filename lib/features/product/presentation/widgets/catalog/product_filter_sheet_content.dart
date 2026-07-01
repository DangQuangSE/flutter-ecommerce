import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_cubit.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_state.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_category_section.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_choice_sections.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_price_section.dart';

class ProductFilterSheetContent extends StatelessWidget {
  final int? categoryId;
  final int? brandId;
  final String? gender;
  final String? color;
  final Set<int> expandedCategories;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final void Function(int? id, String? name) onCategorySelected;
  final void Function(int? id, String? name) onBrandSelected;
  final ValueChanged<int> onCategoryToggled;
  final ValueChanged<String?> onGenderSelected;
  final ValueChanged<String?> onColorSelected;
  final void Function(double? min, double? max) onPricePresetSelected;

  const ProductFilterSheetContent({
    super.key,
    required this.categoryId,
    required this.brandId,
    required this.gender,
    required this.color,
    required this.expandedCategories,
    required this.minPriceController,
    required this.maxPriceController,
    required this.onCategorySelected,
    required this.onBrandSelected,
    required this.onCategoryToggled,
    required this.onGenderSelected,
    required this.onColorSelected,
    required this.onPricePresetSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductFilterOptionsCubit, ProductFilterOptionsState>(
      builder: (context, state) {
        final loading = state is ProductFilterOptionsInitial ||
            state is ProductFilterOptionsLoading;
        final loaded = state is ProductFilterOptionsLoaded ? state : null;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingLg),
          children: [
            ProductFilterCategorySection(
              categories: loaded?.categories ?? const [],
              loading: loading,
              error: loaded?.categoryError,
              selectedId: categoryId,
              expandedIds: expandedCategories,
              onSelect: onCategorySelected,
              onToggleExpand: onCategoryToggled,
            ),
            ProductFilterBrandSection(
              brands: loaded?.brands ?? const [],
              loading: loading,
              error: loaded?.brandError,
              selectedId: brandId,
              onSelect: onBrandSelected,
            ),
            ProductFilterGenderSection(
              selected: gender,
              onSelect: onGenderSelected,
            ),
            ProductFilterColorSection(
              selected: color,
              onSelect: onColorSelected,
            ),
            ProductFilterPriceSection(
              minController: minPriceController,
              maxController: maxPriceController,
              onPreset: onPricePresetSelected,
            ),
            const SizedBox(height: 100),
          ],
        );
      },
    );
  }
}
