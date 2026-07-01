import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_empty_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_error_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:flutter_ecommerce/features/chat/presentation/pages/chat_list_page.dart';

class ChatEntryPage extends StatelessWidget {
  const ChatEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final isAdmin = authState is AuthAuthenticated && authState.user.isAdmin;

    if (isAdmin) return const ChatListPage();
    return const _CustomerChatEntry();
  }
}

class _CustomerChatEntry extends StatefulWidget {
  const _CustomerChatEntry();

  @override
  State<_CustomerChatEntry> createState() => _CustomerChatEntryState();
}

class _CustomerChatEntryState extends State<_CustomerChatEntry> {
  String? _chatId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ChatCubit>().loadChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_chatId != null) {
      return ChatDetailPage(chatId: _chatId!);
    }

    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state case ChatsLoaded(:final chats) when chats.isNotEmpty) {
          setState(() {
            _chatId = chats.first.id;
          });
        }
      },
      builder: (context, state) {
        return switch (state) {
          ChatError(:final message) => Scaffold(
              body: AppErrorView(
                title: AppStrings.chatLoadErrorTitle,
                message: message,
                onRetry: context.read<ChatCubit>().loadChats,
              ),
            ),
          ChatsLoaded(:final chats) when chats.isEmpty => const Scaffold(
              body: AppEmptyView(
                icon: Icons.support_agent_rounded,
                title: AppStrings.chatEmptyTitle,
                message: AppStrings.chatEmptyMessage,
              ),
            ),
          _ => const Scaffold(body: AppLoadingView()),
        };
      },
    );
  }
}
