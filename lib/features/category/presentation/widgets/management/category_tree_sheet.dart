import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_tree_node.dart';

class CategoryTreeSheet extends StatelessWidget {
  final Future<List<CategoryTreeNode>> treeFuture;

  const CategoryTreeSheet({
    super.key,
    required this.treeFuture,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return FutureBuilder<List<CategoryTreeNode>>(
          future: treeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSizes.fontDisplay + 8),
                  child: AppLoadingView(),
                ),
              );
            }

            final nodes = snapshot.data ?? const <CategoryTreeNode>[];
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(
                AppSizes.paddingMd,
                AppSizes.paddingMd,
                AppSizes.paddingMd,
                AppSizes.paddingXl,
              ),
              children: [
                Text(
                  AppStrings.adminCategoryTreeTitle,
                  style: GoogleFonts.lexend(
                    fontSize: AppSizes.fontXl,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingSm + AppSizes.paddingXs),
                if (nodes.isEmpty)
                  Text(
                    AppStrings.adminCategoryTreeEmpty,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.forgotPasswordFontSize,
                      color: AppColors.textSecondary,
                    ),
                  )
                else
                  ..._treeTiles(nodes, 0),
              ],
            );
          },
        );
      },
    );
  }

  List<Widget> _treeTiles(List<CategoryTreeNode> nodes, int depth) {
    final widgets = <Widget>[];

    for (final node in nodes) {
      widgets.add(_TreeTile(node: node, depth: depth));
      widgets.addAll(_treeTiles(node.children, depth + 1));
    }

    return widgets;
  }
}

class _TreeTile extends StatelessWidget {
  final CategoryTreeNode node;
  final int depth;

  const _TreeTile({
    required this.node,
    required this.depth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: depth * AppSizes.paddingLg,
        top: AppSizes.radiusSm,
        bottom: AppSizes.radiusSm,
      ),
      child: Row(
        children: [
          Icon(
            depth == 0
                ? Icons.folder_rounded
                : Icons.subdirectory_arrow_right_rounded,
            size: AppSizes.iconSm + 2,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSizes.paddingSm),
          Expanded(
            child: Text(
              node.name,
              style: GoogleFonts.inter(
                fontSize: AppSizes.forgotPasswordFontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (node.isCustomizable)
            const Icon(
              Icons.brush_rounded,
              size: AppSizes.forgotPasswordFontSize,
              color: AppColors.accent,
            ),
        ],
      ),
    );
  }
}
