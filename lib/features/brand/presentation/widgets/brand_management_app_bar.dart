import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class BrandManagementAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onCreate;

  const BrandManagementAppBar({
    super.key,
    required this.onCreate,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Thương hiệu',
        style: GoogleFonts.lexend(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      actions: [
        IconButton(
          onPressed: onCreate,
          icon: const Icon(
            Icons.add_rounded,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
