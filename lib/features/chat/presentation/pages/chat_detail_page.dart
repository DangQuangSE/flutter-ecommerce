import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';
import 'package:flutter_ecommerce/features/chat/presentation/widgets/detail/chat_detail_app_bar.dart';
import 'package:flutter_ecommerce/features/chat/presentation/widgets/detail/chat_input_bar.dart';
import 'package:flutter_ecommerce/features/chat/presentation/widgets/detail/chat_message_list.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;

  const ChatDetailPage({
    super.key,
    required this.chatId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<ChatState>? _stateSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      final chatCubit = context.read<ChatCubit>();
      chatCubit.loadChatRoom(widget.chatId);
      _stateSubscription = chatCubit.stream.listen((state) {
        if (state is ChatRoomLoaded) {
          _scrollToBottom();
        }
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _stateSubscription?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(widget.chatId, text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        ChatEntity? chatMetadata;
        List<MessageEntity> messages = [];
        bool isLoading = state is ChatLoading;

        if (state is ChatRoomLoaded) {
          chatMetadata = state.chat;
          messages = state.messages;
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: ChatDetailAppBar(chat: chatMetadata),
          body: Column(
            children: [
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : ChatMessageList(
                        messages: messages,
                        chat: chatMetadata,
                        scrollController: _scrollController,
                        onScrollToBottom: _scrollToBottom,
                      ),
              ),
              ChatInputBar(
                controller: _messageController,
                onSend: _handleSendMessage,
              ),
            ],
          ),
        );
      },
    );
  }
}
