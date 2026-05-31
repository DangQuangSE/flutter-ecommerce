import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/notification/domain/entities/notification_entity.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_state.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed(AppRoutes.productList);
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Text(
          'Thông báo',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          } else if (state is NotificationLoaded) {
            final unreadList = state.notifications.where((n) => !n.isRead).toList();
            final readList = state.notifications.where((n) => n.isRead).toList();

            if (state.notifications.isEmpty) {
              return _buildEmptyNotificationsState();
            }

            return _buildNotificationContent(context, unreadList, readList);
          } else if (state is NotificationError) {
            return _buildErrorState(state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyNotificationsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F3F8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Transform(
              transform: Matrix4.skewX(-0.12),
              child: Text(
                'KHÔNG CÓ THÔNG BÁO',
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: AppColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Hộp thư của bạn hiện đang trống. Mọi cập nhật về đơn hàng hoặc ưu đãi đặc biệt sẽ xuất hiện tại đây!',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationContent(
    BuildContext context,
    List<NotificationEntity> unreadList,
    List<NotificationEntity> readList,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MỚI NHẤT',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              if (unreadList.isNotEmpty)
                TextButton(
                  onPressed: () {
                    context.read<NotificationCubit>().markAllAsRead();
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã đánh dấu đọc tất cả thông báo.'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Đánh dấu đã đọc',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Unread/Recent List
          if (unreadList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Không có thông báo chưa đọc mới nào.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: unreadList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = unreadList[index];
                return _buildNotificationCard(context, item);
              },
            ),

          // Divider for Older Notifications
          if (readList.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'TRƯỚC ĐÓ',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Read/Older List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: readList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = readList[index];
                return _buildNotificationCard(context, item);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, NotificationEntity item) {
    IconData iconData;
    Color iconColor;
    Color iconBgColor;

    switch (item.type) {
      case 'order':
        iconData = Icons.local_shipping_outlined;
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primary.withValues(alpha: 0.1);
        break;
      case 'promo':
        iconData = Icons.local_offer_outlined;
        iconColor = AppColors.accent;
        iconBgColor = AppColors.accent.withValues(alpha: 0.1);
        break;
      case 'product':
        iconData = Icons.checkroom_rounded;
        iconColor = AppColors.textPrimary;
        iconBgColor = const Color(0xFFE8E8ED);
        break;
      case 'system':
      default:
        iconData = Icons.system_update_alt_rounded;
        iconColor = AppColors.textSecondary;
        iconBgColor = const Color(0xFFF3F3F8);
        break;
    }

    return GestureDetector(
      onTap: () {
        if (!item.isRead) {
          context.read<NotificationCubit>().markAsRead(item.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFC1C6D7).withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Opacity(
          opacity: item.isRead ? 0.75 : 1.0,
          child: Stack(
            children: [
              // Unread left blue bar
              if (!item.isRead)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(
                    color: AppColors.primary,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: 4), // spacer for left blue bar

                    // Circular Icon Bounding Box
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Text Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: GoogleFonts.lexend(
                                    fontSize: 13,
                                    fontWeight: item.isRead ? FontWeight.w700 : FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (!item.isRead) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.description,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.createdAt,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF717786),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi khi tải danh sách thông báo.',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<NotificationCubit>().loadNotifications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}
