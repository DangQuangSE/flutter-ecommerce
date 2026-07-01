import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';

class CouponManagementAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const CouponManagementAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 20,
        ),
        onPressed: () {
          if (Navigator.of(context).canPop()) Navigator.of(context).pop();
        },
      ),
      title: Text(
        'Quản lý mã giảm giá',
        style: GoogleFonts.lexend(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }
}
