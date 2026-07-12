import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/features/notification/presentation/widgets/notification_bell_icon.dart';

class ProductDetailAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const ProductDetailAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.7),
        ),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.productList);
          }
        },
        icon: Icon(
          Icons.arrow_back_rounded,
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
      ),
      title: Align(
        alignment: Alignment.centerLeft,
        child: Transform(
          transform: Matrix4.skewX(-0.15),
          child: Text(
            AppStrings.brandName,
            style: GoogleFonts.lexend(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
              letterSpacing: -1.2,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3.0,
                  color: theme.colorScheme.surface.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
      ),
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: const NotificationBellIcon(),
        ),
        const _CartActionIcon(),
        const _ChatActionIcon(),
        const SizedBox(width: 12),
      ],
    );
  }
}

class _CartActionIcon extends StatelessWidget {
  const _CartActionIcon();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, cartState) {
        final cartCount = cartState is CartLoaded ? cartState.totalItems : 0;
        return _BadgedIconButton(
          count: cartCount,
          icon: Icons.shopping_cart_outlined,
          onPressed: () => context.pushNamed(AppRoutes.cart),
        );
      },
    );
  }
}

class _ChatActionIcon extends StatelessWidget {
  const _ChatActionIcon();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, chatState) {
        return _BadgedIconButton(
          count: context.read<ChatCubit>().totalUnreadMessages,
          icon: Icons.chat_bubble_outline_rounded,
          onPressed: () => context.pushNamed(AppRoutes.chatList),
        );
      },
    );
  }
}

class _BadgedIconButton extends StatelessWidget {
  final int count;
  final IconData icon;
  final VoidCallback onPressed;

  const _BadgedIconButton({
    required this.count,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
          ),
          onPressed: onPressed,
          icon: Icon(icon, color: AppColors.primary, size: 24),
        ),
        if (count > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
