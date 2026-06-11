import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
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
    _debounce = Timer(const Duration(milliseconds: 500), () {
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // Mobile: Column layout (search on top, controls below) — mirrors web FE flex-col on XS
      child: Column(
        children: [
          // Search row
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              hintStyle: const TextStyle(
                  fontSize: 14, color: AppColors.textHint),
              prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Filter + Sort row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Filter button with active badge
              Stack(
                clipBehavior: Clip.none,
                children: [
                  OutlinedButton.icon(
                    onPressed: widget.onFilterTap,
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: const Text('Bộ lọc'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (widget.hasActiveFilter)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              // Sort dropdown
              _SortDropdown(),
            ],
          ),
        ],
      ),
    );
  }
}

class _SortDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
      buildWhen: (prev, curr) {
        if (prev is ProductCatalogLoaded && curr is ProductCatalogLoaded) {
          return prev.sort != curr.sort;
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
                fontSize: 13,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500),
            borderRadius: BorderRadius.circular(10),
            items: const [
              DropdownMenuItem(
                  value: 'id,desc', child: Text('Mới nhất')),
              DropdownMenuItem(
                  value: 'salePrice,asc', child: Text('Giá tăng dần')),
              DropdownMenuItem(
                  value: 'salePrice,desc', child: Text('Giá giảm dần')),
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
