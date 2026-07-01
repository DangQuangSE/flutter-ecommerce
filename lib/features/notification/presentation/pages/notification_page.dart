import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/utils/ui/app_snack_bar.dart';
import 'package:flutter_ecommerce/core/widgets/app_state_view.dart';
import 'package:flutter_ecommerce/core/widgets/state/app_loading_view.dart';
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
            size: AppSizes.iconMd,
          ),
        ),
        title: Text(
          AppStrings.notificationTitle,
          style: GoogleFonts.lexend(
            fontSize: AppSizes.fontXxl,
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
            return const AppLoadingView();
          } else if (state is NotificationLoaded) {
            final unreadList =
                state.notifications.where((n) => !n.isRead).toList();
            final readList =
                state.notifications.where((n) => n.isRead).toList();

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
    return const AppStateView(
      icon: Icons.notifications_off_outlined,
      title: AppStrings.notificationEmptyTitle,
      message: AppStrings.notificationEmptyMessage,
      iconColor: AppColors.textSecondary,
    );
  }

  Widget _buildNotificationContent(
    BuildContext context,
    List<NotificationEntity> unreadList,
    List<NotificationEntity> readList,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSizes.paddingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.notificationLatestSection,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontSm - 1,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
              if (unreadList.isNotEmpty)
                TextButton(
                  onPressed: () {
                    context.read<NotificationCubit>().markAllAsRead();
                    AppSnackBar.show(
                      context,
                      message: AppStrings.notificationMarkAllReadSuccess,
                      type: AppSnackBarType.success,
                      duration: const Duration(seconds: 1),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    AppStrings.notificationMarkAllRead,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontMd,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSizes.radiusLg),

          // Unread/Recent List
          if (unreadList.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingSm),
              child: Text(
                AppStrings.notificationNoUnread,
                style: GoogleFonts.inter(
                  fontSize: AppSizes.fontMd,
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
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.radiusMd),
              itemBuilder: (context, index) {
                final item = unreadList[index];
                return _buildNotificationCard(context, item);
              },
            ),

          // Divider for Older Notifications
          if (readList.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingXl),
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
                    AppStrings.notificationOlderSection,
                    style: GoogleFonts.inter(
                      fontSize: AppSizes.fontSm - 1,
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
            const SizedBox(height: AppSizes.paddingMd),

            // Read/Older List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: readList.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: AppSizes.radiusMd),
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
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
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
                  width: AppSizes.paddingXs,
                  child: Container(
                    color: AppColors.primary,
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMd),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(width: AppSizes.paddingXs),

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
                          size: AppSizes.iconMd,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSizes.fontLg),

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
                                    fontSize: AppSizes.forgotPasswordFontSize,
                                    fontWeight: item.isRead
                                        ? FontWeight.w700
                                        : FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              if (!item.isRead) ...[
                                const SizedBox(width: AppSizes.paddingSm),
                                Container(
                                  width: AppSizes.paddingSm,
                                  height: AppSizes.paddingSm,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: AppSizes.radiusSm),
                          Text(
                            item.description,
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.fontSm,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppSizes.paddingSm),
                          Text(
                            item.createdAt,
                            style: GoogleFonts.inter(
                              fontSize: AppSizes.fontSm - 1,
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
    return AppStateView(
      icon: Icons.error_outline_rounded,
      title: AppStrings.notificationLoadErrorTitle,
      message: message,
      actionLabel: AppStrings.retry,
      iconColor: AppColors.error,
      onAction: () {
        context.read<NotificationCubit>().loadNotifications();
      },
    );
  }
}
