import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_state.dart';

class CategoryManagementList extends StatelessWidget {
  final CategoryLoaded state;
  final Future<void> Function() onRefresh;
  final ValueChanged<CategoryEntity> onOpenDetail;
  final ValueChanged<CategoryEntity> onEdit;
  final ValueChanged<CategoryEntity> onDelete;
  final ValueChanged<CategoryEntity> onToggle;

  const CategoryManagementList({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
        itemCount: state.categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _CategoryListHeader(state: state);
          }

          final category = state.categories[index - 1];
          return _CategoryTile(
            category: category,
            onOpenDetail: onOpenDetail,
            onEdit: onEdit,
            onDelete: onDelete,
            onToggle: onToggle,
          );
        },
      ),
    );
  }
}

class _CategoryListHeader extends StatelessWidget {
  final CategoryLoaded state;

  const _CategoryListHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${state.totalElements} danh mục',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          if (state.isMutating)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryEntity category;
  final ValueChanged<CategoryEntity> onOpenDetail;
  final ValueChanged<CategoryEntity> onEdit;
  final ValueChanged<CategoryEntity> onDelete;
  final ValueChanged<CategoryEntity> onToggle;

  const _CategoryTile({
    required this.category,
    required this.onOpenDetail,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onOpenDetail(category),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            _CategoryImage(category: category),
            const SizedBox(width: 12),
            Expanded(child: _CategorySummary(category: category)),
            Switch.adaptive(
              value: category.isActive,
              activeThumbColor: AppColors.success,
              onChanged: (_) => onToggle(category),
            ),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textSecondary,
              ),
              onSelected: (value) {
                if (value == 'edit') onEdit(category);
                if (value == 'delete') onDelete(category);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Sửa')),
                PopupMenuItem(value: 'delete', child: Text('Xóa')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryImage extends StatelessWidget {
  final CategoryEntity category;

  const _CategoryImage({required this.category});

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.imageUrl;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.category_rounded,
                color: AppColors.primary,
              ),
            )
          : const Icon(
              Icons.category_rounded,
              color: AppColors.primary,
            ),
    );
  }
}

class _CategorySummary extends StatelessWidget {
  final CategoryEntity category;

  const _CategorySummary({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (category.isCustomizable) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.brush_rounded,
                size: 14,
                color: AppColors.accent,
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          category.slug ?? '—',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
