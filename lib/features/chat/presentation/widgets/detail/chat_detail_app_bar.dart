import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/chat/domain/entities/chat_entity.dart';

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
    final title = chat?.senderName ?? 'Hỗ trợ khách hàng';
    final avatar = chat?.senderAvatar ??
        'https://lh3.googleusercontent.com/aida-public/AB6AXuApsVdGBPiD4UfQ4dq1G7LbkH4_du0P8atXrOzXMPxXIPdU9Evf2fHBiv7n7rkz7-2QwAtRh9jhucCQIhGfbTu8TG-hNBBUayau1uU9dh_oWUZ3jDss2SKaH07vLDY0FuMAutm_7fkiDrxd54uP7jBTk4wMGALX7txCZ23xCJ5rodhCMHV2xtkumkyv6Ln5L36hTGU5DuLjTK5VgukX5QbiLdM1cTUlixcCjb3dHVfOIvJn9iU91V3MsOjneh2RJEq60HzZhkyXIPs';
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
          if (context.canPop()) {
            context.pop();
          } else {
            context.goNamed(AppRoutes.chatList);
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
          _ChatAvatar(
            avatar: avatar,
            isOnline: isOnline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ChatTitle(
              title: title,
              isOnline: isOnline,
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
    );
  }
}
