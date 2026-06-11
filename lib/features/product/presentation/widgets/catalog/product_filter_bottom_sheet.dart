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
  String? _productSize;
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
    _productSize = s.productSize;
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
      _productSize = null;
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
          productSize: _productSize,
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
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
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
                  }),
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
                  }),
                ),
                _GenderSection(
                  selected: _gender,
                  onSelect: (g) => setState(() => _gender = g),
                ),
                _SizeSection(
                  selected: _productSize,
                  onSelect: (s) => setState(() => _productSize = s),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final List<CategoryTreeNode> categories;
  final bool loading;
  final String? error;
  final int? selectedId;
  final Set<int> expandedIds;
  final void Function(int id, String name) onSelect;
  final void Function(int id) onToggleExpand;

  const _CategorySection({
    required this.categories,
    required this.loading,
    this.error,
    required this.selectedId,
    required this.expandedIds,
    required this.onSelect,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Danh mục'),
        if (loading)
          const Center(child: CircularProgressIndicator(strokeWidth: 2))
        else if (error != null)
          Text(error!, style: const TextStyle(color: AppColors.error))
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: SingleChildScrollView(
              child: Column(
                children: categories.map((node) {
                  final isExpanded = expandedIds.contains(node.id);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          if (node.children.isNotEmpty) {
                            onToggleExpand(node.id);
                          } else {
                            onSelect(node.id, node.name);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(node.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: selectedId == node.id
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selectedId == node.id
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                    )),
                              ),
                              if (node.children.isNotEmpty)
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  size: 18,
                                  color: AppColors.textSecondary,
                                ),
                              if (selectedId == node.id)
                                const Icon(Icons.check,
                                    size: 16, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                      if (isExpanded)
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Column(
                            children: node.children.map((child) {
                              return InkWell(
                                onTap: () => onSelect(child.id, child.name),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 7),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(child.name,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: selectedId == child.id
                                                  ? AppColors.primary
                                                  : AppColors.textSecondary,
                                              fontWeight:
                                                  selectedId == child.id
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                            )),
                                      ),
                                      if (selectedId == child.id)
                                        const Icon(Icons.check,
                                            size: 14,
                                            color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        const Divider(),
      ],
    );
  }
}

class _BrandSection extends StatelessWidget {
  final List<BrandEntity> brands;
  final bool loading;
  final int? selectedId;
  final void Function(int id, String name) onSelect;

  const _BrandSection({
    required this.brands,
    required this.loading,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Thương hiệu'),
        if (loading)
          const Center(child: CircularProgressIndicator(strokeWidth: 2))
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 140),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: brands.map((brand) {
                  final selected = selectedId == brand.id;
                  return GestureDetector(
                    onTap: () {
                      if (brand.id != null) onSelect(brand.id!, brand.name);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.divider,
                        ),
                      ),
                      child: Text(
                        brand.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        const Divider(),
      ],
    );
  }
}

class _GenderSection extends StatelessWidget {
  final String? selected;
  final void Function(String? gender) onSelect;

  const _GenderSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const options = [
      (null, 'Tất cả'),
      ('MALE', 'Nam'),
      ('FEMALE', 'Nữ'),
      ('UNISEX', 'Unisex'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Giới tính'),
        Row(
          children: options.map(((String?, String) opt) {
            final (value, label) = opt;
            final isSelected = selected == value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onSelect(value),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        const Divider(),
      ],
    );
  }
}

class _SizeSection extends StatelessWidget {
  final String? selected;
  final void Function(String size) onSelect;

  const _SizeSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final sizes = [
      ...productApparelSizeOrder,
      '38', '39', '40', '41', '42', '43', '44',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Kích thước'),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.2,
          ),
          itemCount: sizes.length,
          itemBuilder: (_, i) {
            final size = sizes[i];
            final isSelected = selected == size;
            return GestureDetector(
              onTap: () => onSelect(size),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : AppColors.divider,
                  ),
                ),
                child: Center(
                  child: Text(
                    size,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }
}

class _ColorSection extends StatelessWidget {
  final String? selected;
  final void Function(String color) onSelect;

  const _ColorSection({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Màu sắc'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: productColorMap.entries.map((entry) {
            final isSelected = selected == entry.key;
            return GestureDetector(
              onTap: () => onSelect(entry.key),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.value,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.divider,
                    width: isSelected ? 2.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        const Divider(),
      ],
    );
  }
}

class _PriceSection extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final void Function(double? min, double? max) onPreset;

  const _PriceSection({
    required this.minController,
    required this.maxController,
    required this.onPreset,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle('Khoảng giá'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: minController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Từ',
                  suffixText: 'đ',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('–', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: TextField(
                controller: maxController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Đến',
                  suffixText: 'đ',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Price presets
        Wrap(
          spacing: 8,
          children: [
            _PresetChip(
              label: 'Dưới 1.000.000đ',
              onTap: () => onPreset(null, 1000000),
            ),
            _PresetChip(
              label: '1 – 3 triệu',
              onTap: () => onPreset(1000000, 3000000),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary)),
      ),
    );
  }
}
