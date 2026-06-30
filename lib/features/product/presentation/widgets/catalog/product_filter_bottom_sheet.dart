import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_cubit.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_state.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_category_section.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_choice_sections.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_price_section.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final ProductCatalogLoaded appliedState;

  const ProductFilterBottomSheet({super.key, required this.appliedState});

  @override
  State<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  int? _categoryId;
  String? _categoryName;
  int? _brandId;
  String? _brandName;
  String? _gender;
  String? _color;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();
  final Set<int> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _syncAppliedFilter();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ProductFilterOptionsCubit>().loadOptions();
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _syncAppliedFilter() {
    final state = widget.appliedState;
    _categoryId = state.categoryId;
    _categoryName = state.categoryName;
    _brandId = state.brandId;
    _brandName = state.brandName;
    _gender = state.gender;
    _color = state.color;
    if (state.minPrice != null) {
      _minPriceController.text = state.minPrice!.toInt().toString();
    }
    if (state.maxPrice != null) {
      _maxPriceController.text = state.maxPrice!.toInt().toString();
    }
  }

  void _resetAll() {
    setState(() {
      _categoryId = null;
      _categoryName = null;
      _brandId = null;
      _brandName = null;
      _gender = null;
      _color = null;
      _minPriceController.clear();
      _maxPriceController.clear();
    });
  }

  void _apply() {
    final minText = _minPriceController.text.trim();
    final maxText = _maxPriceController.text.trim();
    context.read<ProductCatalogBloc>().add(ProductCatalogApplyFilter(
          categoryId: _categoryId,
          categoryName: _categoryName,
          brandId: _brandId,
          brandName: _brandName,
          gender: _gender,
          color: _color,
          minPrice: minText.isNotEmpty ? double.tryParse(minText) : null,
          maxPrice: maxText.isNotEmpty ? double.tryParse(maxText) : null,
        ));
    Navigator.of(context).pop();
  }

  void _selectCategory(int? id, String? name) {
    setState(() {
      _categoryId = id;
      _categoryName = name;
    });
  }

  void _selectBrand(int? id, String? name) {
    setState(() {
      _brandId = id;
      _brandName = name;
    });
  }

  void _toggleCategory(int id) {
    setState(() {
      if (_expandedCategories.contains(id)) {
        _expandedCategories.remove(id);
      } else {
        _expandedCategories.add(id);
      }
    });
  }

  void _setPricePreset(double? min, double? max) {
    setState(() {
      if (min != null) {
        _minPriceController.text = min.toInt().toString();
      } else {
        _minPriceController.clear();
      }
      if (max != null) {
        _maxPriceController.text = max.toInt().toString();
      } else {
        _maxPriceController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusRound),
        ),
      ),
      child: Column(
        children: [
          const _FilterSheetHandle(),
          _FilterSheetHeader(
            onReset: _resetAll,
            onClose: () => Navigator.of(context).pop(),
          ),
          const Divider(height: 1),
          Expanded(
            child: _FilterSheetContent(
              categoryId: _categoryId,
              brandId: _brandId,
              gender: _gender,
              color: _color,
              expandedCategories: _expandedCategories,
              minPriceController: _minPriceController,
              maxPriceController: _maxPriceController,
              onCategorySelected: _selectCategory,
              onBrandSelected: _selectBrand,
              onCategoryToggled: _toggleCategory,
              onGenderSelected: (gender) => setState(() => _gender = gender),
              onColorSelected: (color) => setState(() => _color = color),
              onPricePresetSelected: _setPricePreset,
            ),
          ),
          _FilterSheetActions(
            onReset: _resetAll,
            onApply: _apply,
          ),
        ],
      ),
    );
  }
}

class _FilterSheetHandle extends StatelessWidget {
  const _FilterSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: AppSizes.paddingLg),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
    );
  }
}

class _FilterSheetHeader extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onClose;

  const _FilterSheetHeader({
    required this.onReset,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.paddingLg,
        AppSizes.paddingMd,
        AppSizes.paddingMd,
        0,
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: AppColors.primary),
          AppSizes.spacingSm,
          const Expanded(
            child: Text(
              AppStrings.productFilterTitle,
              style: TextStyle(
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: onReset,
            child: const Text(
              AppStrings.productFilterClearAll,
              style: TextStyle(color: AppColors.error),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _FilterSheetContent extends StatelessWidget {
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

  const _FilterSheetContent({
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

class _FilterSheetActions extends StatelessWidget {
  final VoidCallback onReset;
  final VoidCallback onApply;

  const _FilterSheetActions({
    required this.onReset,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.paddingLg,
          AppSizes.paddingSm,
          AppSizes.paddingLg,
          AppSizes.paddingMd,
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onReset,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
                child: const Text(AppStrings.productFilterReset),
              ),
            ),
            AppSizes.spacingMd,
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMd,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  ),
                ),
                child: const Text(
                  AppStrings.productFilterApply,
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
