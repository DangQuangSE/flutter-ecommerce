import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton(
            onPressed: onClearAll,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Xóa tất cả',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error)),
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
      final label = switch (state.gender!) {
        'MALE' => 'Nam',
        'FEMALE' => 'Nữ',
        'UNISEX' => 'Unisex',
        _ => state.gender!,
      };
      chips.add(_Chip(
        label: label,
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
      final min = state.minPrice;
      final max = state.maxPrice;
      String label;
      if (min != null && max != null) {
        label = '${_fmtPrice(min)} – ${_fmtPrice(max)}';
      } else if (min != null) {
        label = 'Từ ${_fmtPrice(min)}';
      } else {
        label = 'Đến ${_fmtPrice(max!)}';
      }
      chips.add(_Chip(
        label: label,
        onDelete: () => context.read<ProductCatalogBloc>().add(
              ProductCatalogFilterChanged(
                  clearMinPrice: true, clearMaxPrice: true, silent: true),
            ),
      ));
    }

    return chips;
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  String _fmtPrice(double p) {
    final n = p.toInt();
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(n % 1000000 == 0 ? 0 : 1)}M';
    }
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return '${n}đ';
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _Chip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close,
                size: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
