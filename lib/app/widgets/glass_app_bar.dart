import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_state.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/features/notification/presentation/widgets/notification_bell_icon.dart';

class GlassAppBar extends StatelessWidget {
  final bool showBackButton;
  final String? customTitle;

  const GlassAppBar({
    super.key,
    this.showBackButton = false,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.8),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (showBackButton)
                GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.goNamed(AppRoutes.home);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        customTitle ?? 'Trở về',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: () => context.goNamed(AppRoutes.home),
                  child: Transform(
                    transform: Matrix4.skewX(-0.12),
                    child: Text(
                      customTitle ?? 'Sport Pro',
                      style: GoogleFonts.lexend(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              const _AppBarActions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBarActions extends StatelessWidget {
  const _AppBarActions();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const NotificationBellIcon(),
        BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            final cartCount =
                cartState is CartLoaded ? cartState.totalItems : 0;
            return _BadgeIconButton(
              icon: Icons.shopping_cart_outlined,
              count: cartCount,
              onPressed: () => context.pushNamed(AppRoutes.cart),
            );
          },
        ),
        BlocBuilder<ChatCubit, ChatState>(
          builder: (context, chatState) {
            final unreadCount = context.read<ChatCubit>().totalUnreadMessages;
            return _BadgeIconButton(
              icon: Icons.chat_bubble_outline_rounded,
              count: unreadCount,
              onPressed: () => context.pushNamed(AppRoutes.chatList),
            );
          },
        ),
      ],
    );
  }
}

class _BadgeIconButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final VoidCallback onPressed;

  const _BadgeIconButton({
    required this.icon,
    required this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: AppColors.textPrimary,
            size: 21,
          ),
        ),
        if (count > 0)
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 14,
                minHeight: 14,
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
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
