import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';

class ChatListAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatListAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      leading: IconButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.home);
          }
        },
        icon: Icon(
          Icons.arrow_back_rounded,
          color: theme.colorScheme.onSurface,
          size: AppSizes.paddingXl,
        ),
      ),
      titleSpacing: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: theme.dividerColor,
          height: 1,
        ),
      ),
      title: Transform(
        transform: Matrix4.skewX(-0.12),
        child: Text(
          AppStrings.chatListTitle,
          style: GoogleFonts.lexend(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          onPressed: () {
            AppSnackBar.show(
              context,
              message: AppStrings.chatHotlineMessage,
              type: AppSnackBarType.info,
            );
          },
          icon: const Icon(
            Icons.support_agent_rounded,
            color: AppColors.primary,
            size: AppSizes.paddingXl,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
