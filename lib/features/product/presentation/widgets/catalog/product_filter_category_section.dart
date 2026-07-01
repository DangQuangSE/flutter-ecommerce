import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';
import 'package:flutter_ecommerce/features/product/presentation/widgets/catalog/product_filter_section_title.dart';

class ProductFilterCategorySection extends StatelessWidget {
  final List<CategoryTreeNode> categories;
  final bool loading;
  final String? error;
  final int? selectedId;
  final Set<int> expandedIds;
  final void Function(int? id, String? name) onSelect;
  final void Function(int id) onToggleExpand;

  const ProductFilterCategorySection({
    super.key,
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
        const ProductFilterSectionTitle(AppStrings.productFilterCategory),
        if (loading)
          const AppLoadingView(size: AppSizes.paddingXl)
        else if (error != null)
          Text(error!, style: const TextStyle(color: AppColors.error))
        else
          _CategoryTree(
            categories: categories,
            selectedId: selectedId,
            expandedIds: expandedIds,
            onSelect: onSelect,
            onToggleExpand: onToggleExpand,
          ),
        const Divider(),
      ],
    );
  }
}

class _CategoryTree extends StatelessWidget {
  final List<CategoryTreeNode> categories;
  final int? selectedId;
  final Set<int> expandedIds;
  final void Function(int? id, String? name) onSelect;
  final void Function(int id) onToggleExpand;

  const _CategoryTree({
    required this.categories,
    required this.selectedId,
    required this.expandedIds,
    required this.onSelect,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 180),
      child: SingleChildScrollView(
        child: Column(
          children: categories
              .map(
                (node) => _CategoryNodeTile(
                  node: node,
                  selectedId: selectedId,
                  expandedIds: expandedIds,
                  onSelect: onSelect,
                  onToggleExpand: onToggleExpand,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _CategoryNodeTile extends StatelessWidget {
  final CategoryTreeNode node;
  final int? selectedId;
  final Set<int> expandedIds;
  final void Function(int? id, String? name) onSelect;
  final void Function(int id) onToggleExpand;

  const _CategoryNodeTile({
    required this.node,
    required this.selectedId,
    required this.expandedIds,
    required this.onSelect,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded = expandedIds.contains(node.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CategoryRow(
          id: node.id,
          name: node.name,
          selectedId: selectedId,
          hasChildren: node.children.isNotEmpty,
          isExpanded: isExpanded,
          onSelect: onSelect,
          onToggleExpand: onToggleExpand,
        ),
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.only(left: AppSizes.paddingMd),
            child: Column(
              children: node.children
                  .map(
                    (child) => _CategoryChildRow(
                      child: child,
                      selectedId: selectedId,
                      onSelect: onSelect,
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final int id;
  final String name;
  final int? selectedId;
  final bool hasChildren;
  final bool isExpanded;
  final void Function(int? id, String? name) onSelect;
  final void Function(int id) onToggleExpand;

  const _CategoryRow({
    required this.id,
    required this.name,
    required this.selectedId,
    required this.hasChildren,
    required this.isExpanded,
    required this.onSelect,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (hasChildren) {
          onToggleExpand(id);
        } else if (selectedId == id) {
          onSelect(null, null);
        } else {
          onSelect(id, name);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: AppSizes.fontLg,
                  fontWeight:
                      selectedId == id ? FontWeight.w700 : FontWeight.w500,
                  color: selectedId == id
                      ? AppColors.primary
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (hasChildren)
              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                size: AppSizes.fontXxl,
                color: AppColors.textSecondary,
              ),
            if (selectedId == id)
              const Icon(
                Icons.check,
                size: AppSizes.fontXl,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChildRow extends StatelessWidget {
  final CategoryTreeNode child;
  final int? selectedId;
  final void Function(int? id, String? name) onSelect;

  const _CategoryChildRow({
    required this.child,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedId == child.id;

    return InkWell(
      onTap: () =>
          isSelected ? onSelect(null, null) : onSelect(child.id, child.name),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSizes.radiusSm),
        child: Row(
          children: [
            Expanded(
              child: Text(
                child.name,
                style: TextStyle(
                  fontSize: AppSizes.forgotPasswordFontSize,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: AppSizes.fontLg,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
