import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/app/theme/app_colors.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_state.dart';

class NotificationBellIcon extends StatefulWidget {
  const NotificationBellIcon({super.key});

  @override
  State<NotificationBellIcon> createState() => _NotificationBellIconState();
}

class _NotificationBellIconState extends State<NotificationBellIcon> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pingScale;
  late Animation<double> _pingOpacity;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Simulate Tailwind animate-ping (scale up and fade out)
    _pingScale = Tween<double>(begin: 1.0, end: 2.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    _pingOpacity = Tween<double>(begin: 0.75, end: 0.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeOut,
      ),
    );

    // Let the animation repeat infinitely
    _pulseController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationLoaded) {
          unreadCount = state.unreadCount;
        }

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            IconButton(
              onPressed: () => context.goNamed(AppRoutes.notificationList),
              icon: const Icon(
                Icons.notifications_none_outlined,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Pulsing Ring (Tailwind animate-ping)
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pingScale.value,
                          child: Opacity(
                            opacity: _pingOpacity.value,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Solid Badge Core with count
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$unreadCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 7.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
