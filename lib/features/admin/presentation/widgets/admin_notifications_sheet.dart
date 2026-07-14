import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_state.dart';

class AdminNotificationsSheet extends StatelessWidget {
  const AdminNotificationsSheet({super.key, required this.state});

  static void show(BuildContext context, AdminNotificationState state) {
    context.read<AdminNotificationCubit>().markAllAsRead();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AdminNotificationCubit>(),
        child: AdminNotificationsSheet(state: state),
      ),
    );
  }

  final AdminNotificationState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.adminNotificationSheetTitle,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          if (state.notifications.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                AppStrings.adminNotificationEmpty,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final notif = state.notifications[index];
                  return Opacity(
                    opacity: notif.isRead ? 0.6 : 1.0,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          if (!notif.isRead)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        notif.title.isNotEmpty
                            ? notif.title
                            : AppStrings.adminNotificationDefaultTitle,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight:
                              notif.isRead ? FontWeight.w500 : FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notif.message,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppStrings.adminNotificationOrderText(
                                notif.orderId, notif.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(
                          AppRoutes.adminOrderDetail,
                          pathParameters: {
                            'orderId': notif.orderId.toString()
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
