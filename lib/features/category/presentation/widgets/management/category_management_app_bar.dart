import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class CategoryManagementAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback onOpenTree;

  const CategoryManagementAppBar({
    super.key,
    required this.onOpenTree,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () {
          if (context.canPop()) context.pop();
        },
      ),
      title: Text(
        'Quản lý danh mục',
        style: GoogleFonts.lexend(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          tooltip: 'Xem cây danh mục',
          icon: const Icon(
            Icons.account_tree_outlined,
            color: AppColors.textPrimary,
            size: 22,
          ),
          onPressed: onOpenTree,
        ),
      ],
    );
  }
}
