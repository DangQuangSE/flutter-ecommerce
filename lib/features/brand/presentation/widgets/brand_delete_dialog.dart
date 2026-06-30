import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/brand/domain/entities/brand_entity.dart';

class BrandDeleteDialog extends StatelessWidget {
  final BrandEntity brand;
  final VoidCallback onConfirm;

  const BrandDeleteDialog({
    super.key,
    required this.brand,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'Xóa thương hiệu?',
        style: GoogleFonts.lexend(fontWeight: FontWeight.w700),
      ),
      content: Text(
        'Bạn có chắc chắn muốn xóa thương hiệu "${brand.name}"? Hành động này không thể hoàn tác.',
        style: GoogleFonts.inter(fontSize: 14),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'HỦY',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'XÓA',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}
