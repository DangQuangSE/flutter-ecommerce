import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_cubit.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_sheet_chrome.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_sheet_content.dart';

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
          const ProductFilterSheetHandle(),
          ProductFilterSheetHeader(
            onReset: _resetAll,
            onClose: () => Navigator.of(context).pop(),
          ),
          const Divider(height: 1),
          Expanded(
            child: ProductFilterSheetContent(
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
          ProductFilterSheetActions(
            onReset: _resetAll,
            onApply: _apply,
          ),
        ],
      ),
    );
  }
}
