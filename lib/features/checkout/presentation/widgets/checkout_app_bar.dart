import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';

class CheckoutAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CheckoutAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor:
          theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
          height: 1,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.cart);
          }
        },
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: theme.colorScheme.onSurface,
          size: 20,
        ),
      ),
      title: Text(
        AppStrings.checkoutTitle,
        style: GoogleFonts.lexend(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
      ),
      centerTitle: true,
    );
  }
}
