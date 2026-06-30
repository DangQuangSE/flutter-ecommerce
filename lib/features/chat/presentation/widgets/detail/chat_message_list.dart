import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/message_entity.dart';

class ChatMessageList extends StatelessWidget {
  final List<MessageEntity> messages;
  final ChatEntity? chat;
  final ScrollController scrollController;
  final VoidCallback onScrollToBottom;

  const ChatMessageList({
    super.key,
    required this.messages,
    required this.chat,
    required this.scrollController,
    required this.onScrollToBottom,
  });

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'Chưa có tin nhắn nào. Bắt đầu cuộc trò chuyện!',
          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textHint),
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => onScrollToBottom());

    return ListView.builder(
      controller: scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: messages.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _TimestampDivider();
        }

        return _MessageBubble(
          message: messages[index - 1],
          chat: chat,
        );
      },
    );
  }
}

class _TimestampDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}

class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final ChatEntity? chat;

  const _MessageBubble({
    required this.message,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isMe) {
      return message.isSystem
          ? _OutgoingSystemBubble(message: message)
          : _OutgoingTextBubble(message: message);
    }

    return _IncomingBubble(
      message: message,
      chat: chat,
    );
  }
}

class _OutgoingSystemBubble extends StatelessWidget {
  final MessageEntity message;

  const _OutgoingSystemBubble({required this.message});

  @override
  Widget build(BuildContext context) {
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
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.design_services_rounded,
                  color: Color(0xFFFFB874),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(child: _OutgoingMessageText(message.content)),
              ],
            ),
            const SizedBox(height: 6),
            _OutgoingTimestamp(timestamp: message.timestamp),
          ],
        ),
      ),
    );
  }
}

class _OutgoingTextBubble extends StatelessWidget {
  final MessageEntity message;

  const _OutgoingTextBubble({required this.message});

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _OutgoingMessageText(message.content),
            const SizedBox(height: 4),
            _OutgoingTimestamp(timestamp: message.timestamp),
          ],
        ),
      ),
    );
  }
}

class _IncomingBubble extends StatelessWidget {
  final MessageEntity message;
  final ChatEntity? chat;

  const _IncomingBubble({
    required this.message,
    required this.chat,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _IncomingAvatar(avatar: chat?.senderAvatar),
            Expanded(child: _IncomingContent(message: message)),
          ],
        ),
      ),
    );
  }
}

class _IncomingAvatar extends StatelessWidget {
  final String? avatar;

  const _IncomingAvatar({required this.avatar});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E2E7), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        avatar ??
            'https://lh3.googleusercontent.com/aida-public/AB6AXuApsVdGBPiD4UfQ4dq1G7LbkH4_du0P8atXrOzXMPxXIPdU9Evf2fHBiv7n7rkz7-2QwAtRh9jhucCQIhGfbTu8TG-hNBBUayau1uU9dh_oWUZ3jDss2SKaH07vLDY0FuMAutm_7fkiDrxd54uP7jBTk4wMGALX7txCZ23xCJ5rodhCMHV2xtkumkyv6Ln5L36hTGU5DuLjTK5VgukX5QbiLdM1cTUlixcCjb3dHVfOIvJn9iU91V3MsOjneh2RJEq60HzZhkyXIPs',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _IncomingContent extends StatelessWidget {
  final MessageEntity message;

  const _IncomingContent({required this.message});

  @override
  Widget build(BuildContext context) {
    final hasImage = message.imageUrl != null;

    return Container(
      padding: hasImage
          ? const EdgeInsets.all(4)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEDF2),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
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
          if (hasImage) ...[
            _MessageImage(url: message.imageUrl!),
            _IncomingMessagePadding(child: _IncomingText(message.content)),
          ] else ...[
            _IncomingText(message.content),
          ],
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: hasImage
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
    );
  }
}

class _MessageImage extends StatelessWidget {
  final String url;

  const _MessageImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _IncomingMessagePadding extends StatelessWidget {
  final Widget child;

  const _IncomingMessagePadding({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: child,
    );
  }
}

class _OutgoingMessageText extends StatelessWidget {
  final String text;

  const _OutgoingMessageText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: Colors.white,
        height: 1.4,
      ),
    );
  }
}

class _IncomingText extends StatelessWidget {
  final String text;

  const _IncomingText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
        height: 1.4,
      ),
    );
  }
}

class _OutgoingTimestamp extends StatelessWidget {
  final String timestamp;

  const _OutgoingTimestamp({required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Text(
        timestamp,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
