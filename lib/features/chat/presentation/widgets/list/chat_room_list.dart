import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';

class ChatRoomList extends StatelessWidget {
  final List<ChatEntity> chats;
  final String selectedFilter;
  final String searchQuery;

  const ChatRoomList({
    super.key,
    required this.chats,
    required this.selectedFilter,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = chats.where(_matchesFilter).toList();

    if (filtered.isEmpty) {
      return const _EmptyChatRooms();
    }

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ChatRoomCard(chat: filtered[index]);
      },
    );
  }

  bool _matchesFilter(ChatEntity chat) {
    final matchesSearch = chat.senderName.toLowerCase().contains(searchQuery) ||
        chat.lastMessage.toLowerCase().contains(searchQuery);

    final matchesTab = switch (selectedFilter) {
      'unread' => chat.unreadCount > 0,
      'support' => chat.tag == 'Hỗ trợ',
      _ => true,
    };

    return matchesSearch && matchesTab;
  }
}

class _EmptyChatRooms extends StatelessWidget {
  const _EmptyChatRooms();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy cuộc hội thoại nào.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRoomCard extends StatelessWidget {
  final ChatEntity chat;

  const _ChatRoomCard({required this.chat});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.chatDetail,
          pathParameters: {'chatId': chat.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasUnread
                ? AppColors.primary.withValues(alpha: 0.2)
                : const Color(0xFFC1C6D7).withValues(alpha: 0.25),
            width: hasUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _ChatRoomAvatar(chat: chat),
              const SizedBox(width: 14),
              Expanded(child: _ChatRoomSummary(chat: chat)),
              const SizedBox(width: 8),
              _ChatRoomMeta(chat: chat),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatRoomAvatar extends StatelessWidget {
  final ChatEntity chat;

  const _ChatRoomAvatar({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E2E7),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            chat.senderAvatar,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 24),
          ),
        ),
        if (chat.isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _ChatRoomSummary extends StatelessWidget {
  final ChatEntity chat;

  const _ChatRoomSummary({required this.chat});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                chat.senderName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (chat.tag != null) ...[
              const SizedBox(width: 6),
              _ChatTag(tag: chat.tag!),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          chat.lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
            color: hasUnread ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ChatTag extends StatelessWidget {
  final String tag;

  const _ChatTag({required this.tag});

  @override
  Widget build(BuildContext context) {
    final isShop = tag == 'Shop';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isShop
            ? AppColors.accent.withValues(alpha: 0.12)
            : AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: isShop ? AppColors.accent : AppColors.primary,
        ),
      ),
    );
  }
}

class _ChatRoomMeta extends StatelessWidget {
  final ChatEntity chat;

  const _ChatRoomMeta({required this.chat});

  @override
  Widget build(BuildContext context) {
    final hasUnread = chat.unreadCount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          chat.lastMessageTime,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: hasUnread ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (chat.associatedProductImage != null) ...[
              _AssociatedProductImage(url: chat.associatedProductImage!),
              const SizedBox(width: 6),
            ],
            if (hasUnread) _UnreadBadge(count: chat.unreadCount),
          ],
        ),
      ],
    );
  }
}

class _AssociatedProductImage extends StatelessWidget {
  final String url;

  const _AssociatedProductImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFC1C6D7).withValues(alpha: 0.4),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;

  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
      constraints: const BoxConstraints(
        minWidth: 18,
        minHeight: 18,
      ),
      child: Text(
        '$count',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
