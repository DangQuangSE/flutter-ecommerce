import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';

class CategoryDetailSheet extends StatelessWidget {
  final CategoryEntity category;

  const CategoryDetailSheet({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            category.name,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'ID', value: '${category.id ?? '—'}'),
          _DetailRow(label: 'Slug', value: category.slug ?? '—'),
          _DetailRow(
            label: 'Mô tả',
            value: (category.description ?? '').isEmpty
                ? '—'
                : category.description!,
          ),
          _DetailRow(
            label: 'Danh mục cha',
            value: category.parentId?.toString() ?? 'Không có',
          ),
          _DetailRow(
            label: 'Thứ tự',
            value: category.displayOrder?.toString() ?? '—',
          ),
          _DetailRow(
            label: 'Trạng thái',
            value: category.isActive ? 'Đang hoạt động' : 'Tạm ẩn',
          ),
          _DetailRow(
            label: 'Tùy chỉnh',
            value: category.isCustomizable ? 'Có' : 'Không',
          ),
          _DetailRow(
            label: 'Tạo lúc',
            value: category.createdAt?.toString().split('.').first ?? '—',
          ),
          _DetailRow(
            label: 'Cập nhật',
            value: category.updatedAt?.toString().split('.').first ?? '—',
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
