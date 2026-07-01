import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/widgets/detail/chat_detail_skeleton.dart';

class ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatEntity? chat;

  const ChatDetailAppBar({
    super.key,
    required this.chat,
  });

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
          color: theme.dividerColor.withValues(alpha: 0.3),
          height: 1,
        ),
      ),
      leadingWidth: 44,
      leading: IconButton(
        onPressed: () => _handleBackPressed(context),
        icon: Icon(
          Icons.arrow_back_rounded,
          color: theme.colorScheme.onSurface,
          size: AppSizes.paddingXl,
        ),
      ),
      title: Row(
        children: [
          Expanded(child: _ChatHeaderContent(chat: chat)),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            AppSnackBar.show(
              context,
              message: AppStrings.chatEscalationMessage,
              type: AppSnackBarType.info,
            );
          },
          icon: Icon(
            Icons.more_vert_rounded,
            color: Theme.of(context).colorScheme.onSurface,
            size: AppSizes.paddingXl,
          ),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  void _handleBackPressed(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final shouldRefreshChatList =
        authState is AuthAuthenticated && authState.user.isAdmin;
    final chatCubit = shouldRefreshChatList ? context.read<ChatCubit>() : null;

    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(AppRoutes.chatList);
    }

    if (chatCubit != null) {
      Future.microtask(chatCubit.loadChats);
    }
  }
}

class _ChatHeaderContent extends StatelessWidget {
  final ChatEntity? chat;

  const _ChatHeaderContent({required this.chat});

  @override
  Widget build(BuildContext context) {
    final currentChat = chat;
    if (currentChat == null) {
      return const ChatHeaderSkeleton();
    }

    return Row(
      children: [
        _ChatAvatar(
          avatar: currentChat.senderAvatar,
          isOnline: currentChat.isOnline,
        ),
        SizedBox(width: AppSizes.radiusLg),
        Expanded(
          child: _ChatTitle(
            title: currentChat.senderName,
            isOnline: currentChat.isOnline,
          ),
        ),
      ],
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  final String avatar;
  final bool isOnline;

  const _ChatAvatar({
    required this.avatar,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            avatar,
            fit: BoxFit.cover,
          ),
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: AppSizes.radiusMd,
              height: AppSizes.radiusMd,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                    color: Theme.of(context).colorScheme.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChatTitle extends StatelessWidget {
  final String title;
  final bool isOnline;

  const _ChatTitle({
    required this.title,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: GoogleFonts.lexend(
            fontSize: AppSizes.submitButtonFontSize,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 2),
        Text(
          isOnline ? AppStrings.chatOnline : AppStrings.chatOffline,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: isOnline ? AppColors.textSecondary : AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
