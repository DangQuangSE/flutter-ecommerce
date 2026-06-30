import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
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
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              );
            }

            final nodes = snapshot.data ?? const <CategoryTreeNode>[];
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Text(
                  'Cây danh mục',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (nodes.isEmpty)
                  Text(
                    'Không có dữ liệu.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
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
      padding: EdgeInsets.only(left: depth * 20.0, top: 6, bottom: 6),
      child: Row(
        children: [
          Icon(
            depth == 0
                ? Icons.folder_rounded
                : Icons.subdirectory_arrow_right_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              node.name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (node.isCustomizable)
            const Icon(
              Icons.brush_rounded,
              size: 13,
              color: AppColors.accent,
            ),
        ],
      ),
    );
  }
}
