import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_state.dart';

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
  late StreamSubscription<ChatState> _stateSubscription;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<ChatCubit>().loadChatRoom(widget.chatId);
    });

    // Auto scroll to bottom when a new state is emitted
    _stateSubscription = context.read<ChatCubit>().stream.listen((state) {
      if (state is ChatRoomLoaded) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _stateSubscription.cancel();
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
          appBar: _buildAppBar(context, chatMetadata),
          body: Column(
            children: [
              // 1. Message Stream Area
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      )
                    : _buildMessageList(messages, chatMetadata),
              ),

              // 2. Input footer bar
              _buildInputBar(context),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, ChatEntity? chat) {
    final title = chat?.senderName ?? 'Hỗ trợ khách hàng';
    final avatar = chat?.senderAvatar ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuApsVdGBPiD4UfQ4dq1G7LbkH4_du0P8atXrOzXMPxXIPdU9Evf2fHBiv7n7rkz7-2QwAtRh9jhucCQIhGfbTu8TG-hNBBUayau1uU9dh_oWUZ3jDss2SKaH07vLDY0FuMAutm_7fkiDrxd54uP7jBTk4wMGALX7txCZ23xCJ5rodhCMHV2xtkumkyv6Ln5L36hTGU5DuLjTK5VgukX5QbiLdM1cTUlixcCjb3dHVfOIvJn9iU91V3MsOjneh2RJEq60HzZhkyXIPs';
    final isOnline = chat?.isOnline ?? true;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
          height: 1,
        ),
      ),
      leadingWidth: 44,
      leading: IconButton(
        onPressed: () {
          // Go back to the chat list or products
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/chats');
          }
        },
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      title: Row(
        children: [
          // Circular Avatar with online indicator
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
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
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // User Metadata
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline ? 'Đang hoạt động' : 'Ngoại tuyến',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isOnline ? AppColors.textSecondary : AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Yêu cầu hỗ trợ đã được chuyển tiếp đến giám sát viên.',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                ),
                backgroundColor: AppColors.primary,
              ),
            );
          },
          icon: const Icon(
            Icons.more_vert_rounded,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMessageList(List<MessageEntity> messages, ChatEntity? chat) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Chưa có tin nhắn nào. Bắt đầu cuộc trò chuyện!',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint),
        ),
      );
    }

    // Trigger initial scrolling to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length + 1, // Adding 1 for the initial timestamp divider
      itemBuilder: (context, index) {
        if (index == 0) {
          // Designed static timestamp separator
          return Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Hôm nay, 09:41',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        }

        final message = messages[index - 1];
        return _buildMessageBubble(message, chat);
      },
    );
  }

  Widget _buildMessageBubble(MessageEntity message, ChatEntity? chat) {
    final bool isMe = message.isMe;

    if (isMe) {
      // Outgoing messages
      if (message.isSystem) {
        // High contrast system/service bubble matching figma with design_services icon
        return Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(0),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.design_services_rounded,
                      color: Color(0xFFFFB874), // Orange accent Dim
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message.content,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    message.timestamp,
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Standard outgoing text bubble
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(0),
            ),
          ),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.content,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.timestamp,
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Incoming messages (Left side)
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  chat?.senderAvatar ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuApsVdGBPiD4UfQ4dq1G7LbkH4_du0P8atXrOzXMPxXIPdU9Evf2fHBiv7n7rkz7-2QwAtRh9jhucCQIhGfbTu8TG-hNBBUayau1uU9dh_oWUZ3jDss2SKaH07vLDY0FuMAutm_7fkiDrxd54uP7jBTk4wMGALX7txCZ23xCJ5rodhCMHV2xtkumkyv6Ln5L36hTGU5DuLjTK5VgukX5QbiLdM1cTUlixcCjb3dHVfOIvJn9iU91V3MsOjneh2RJEq60HzZhkyXIPs',
                  fit: BoxFit.cover,
                ),
              ),

              // Content Bubble
              Expanded(
                child: Container(
                  padding: message.imageUrl != null
                      ? const EdgeInsets.all(4)
                      : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDF2),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: const Color(0xFFE2E2E7),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // If there is an image attachment inside bubble
                      if (message.imageUrl != null) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            message.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            message.content,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          message.content,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                          padding: message.imageUrl != null
                              ? const EdgeInsets.only(right: 8, bottom: 4)
                              : EdgeInsets.zero,
                          child: Text(
                            message.timestamp,
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildInputBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).viewInsets.bottom + 12),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Plus/Attachment button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tải lên ảnh đính kèm (Figma mockup).',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w500),
                    ),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFC1C6D7).withValues(alpha: 0.5), width: 1.5),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
            ),

            // Textfield & Emoji wrapper
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        maxLines: 4,
                        minLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _handleSendMessage(),
                        decoration: InputDecoration(
                          hintText: 'Nhập tin nhắn...',
                          hintStyle: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          isDense: true,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Emoji trigger stub
                        _messageController.text += ' 😊';
                      },
                      child: const Icon(
                        Icons.sentiment_satisfied_alt_rounded,
                        color: AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Send button
            GestureDetector(
              onTap: _handleSendMessage,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent, // Safety Orange
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
