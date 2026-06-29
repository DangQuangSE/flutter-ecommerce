import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';
import 'package:flutter_ecommerce/features/brand/domain/repositories/brand_repository.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/category/domain/repositories/category_repository.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/utils/product_constants.dart';

part 'product_filter_category_section.dart';
part 'product_filter_choice_sections.dart';
part 'product_filter_price_section.dart';

class ProductFilterBottomSheet extends StatefulWidget {
  final ProductCatalogLoaded appliedState;

  const ProductFilterBottomSheet({super.key, required this.appliedState});

  @override
  State<ProductFilterBottomSheet> createState() =>
      _ProductFilterBottomSheetState();
}

class _ProductFilterBottomSheetState extends State<ProductFilterBottomSheet> {
  // Pending filter state — local copy, not applied until Apply tapped
  int? _categoryId;
  String? _categoryName;
  int? _brandId;
  String? _brandName;
  String? _gender;
  String? _color;
  final _minPriceController = TextEditingController();
  final _maxPriceController = TextEditingController();

  // UI state
  final Set<int> _expandedCategories = {};
  bool _loadingCategories = true;
  bool _loadingBrands = true;
  List<CategoryTreeNode> _categories = [];
  List<BrandEntity> _brands = [];
  String? _loadError;

  @override
  void initState() {
    super.initState();
    // Init pending filter from applied state (not from Bloc — snapshot at open time)
    final s = widget.appliedState;
    _categoryId = s.categoryId;
    _categoryName = s.categoryName;
    _brandId = s.brandId;
    _brandName = s.brandName;
    _gender = s.gender;
    _color = s.color;
    if (s.minPrice != null) {
      _minPriceController.text = s.minPrice!.toInt().toString();
    }
    if (s.maxPrice != null) {
      _maxPriceController.text = s.maxPrice!.toInt().toString();
    }
    _loadData();
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Use sl<> (GetIt) — repositories are NOT in the Flutter provider tree
    final catResult = await sl<CategoryRepository>().getTree();
    final brandResult = await sl<BrandRepository>().getBrands(size: 200);
    if (!mounted) return;
    setState(() {
      _loadingCategories = false;
      _loadingBrands = false;
      if (catResult case Success(:final data)) {
        _categories = data;
      } else {
        _loadError = 'Không tải được danh mục';
      }
      if (brandResult case Success(:final data)) {
        _brands = data.where((b) => b.isActive).toList();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.92,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Bộ lọc',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ),
                TextButton(
                  onPressed: _resetAll,
                  child: const Text('Xóa tất cả',
                      style: TextStyle(color: AppColors.error)),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _CategorySection(
                  categories: _categories,
                  loading: _loadingCategories,
                  error: _loadError,
                  selectedId: _categoryId,
                  expandedIds: _expandedCategories,
                  onSelect: (id, name) => setState(() {
                    _categoryId = id;
                    _categoryName = name;
                  }), // null id/name = deselect
                  onToggleExpand: (id) => setState(() {
                    if (_expandedCategories.contains(id)) {
                      _expandedCategories.remove(id);
                    } else {
                      _expandedCategories.add(id);
                    }
                  }),
                ),
                _BrandSection(
                  brands: _brands,
                  loading: _loadingBrands,
                  selectedId: _brandId,
                  onSelect: (id, name) => setState(() {
                    _brandId = id;
                    _brandName = name;
                  }), // null = deselect
                ),
                _GenderSection(
                  selected: _gender,
                  onSelect: (g) => setState(() => _gender = g),
                ),
                _ColorSection(
                  selected: _color,
                  onSelect: (c) => setState(() => _color = c),
                ),
                _PriceSection(
                  minController: _minPriceController,
                  maxController: _maxPriceController,
                  onPreset: (min, max) => setState(() {
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
                  }),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // Apply button — pinned at bottom
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetAll,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Đặt lại'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _apply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Áp dụng',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section widgets ────────────────────────────────────────────────────────────
