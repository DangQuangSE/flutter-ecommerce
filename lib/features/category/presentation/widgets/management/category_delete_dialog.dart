import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/category/domain/entities/category_entity.dart';

class CategoryDeleteDialog extends StatelessWidget {
  final CategoryEntity category;

  const CategoryDeleteDialog({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Xóa danh mục',
        style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Bạn có chắc muốn xóa "${category.name}"?',
        style: GoogleFonts.inter(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Xóa'),
        ),
      ],
    );
  }
}
