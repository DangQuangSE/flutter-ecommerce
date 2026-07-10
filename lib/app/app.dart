import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ecommerce/app/router/app_router.dart';
import 'package:flutter_ecommerce/app/theme/app_theme.dart';
import 'package:flutter_ecommerce/core/constants/app_constants.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_ecommerce/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:flutter_ecommerce/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/customizer_cubit.dart';
import 'package:flutter_ecommerce/app/theme/theme_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_notification_state.dart';
import 'package:flutter_ecommerce/core/utils/notification_service.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final StreamSubscription<String> _payloadSub;

  @override
  void initState() {
    super.initState();
    _payloadSub = sl<NotificationService>().payloadStream.stream.listen((payload) {
      AppRouter.router.push(payload);
    });
  }

  @override
  void dispose() {
    _payloadSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<CartCubit>(create: (_) => sl<CartCubit>()),
        BlocProvider<ProfileCubit>(create: (_) => sl<ProfileCubit>()),
        BlocProvider<NotificationCubit>(
          create: (_) => sl<NotificationCubit>()..loadNotifications(),
        ),
        BlocProvider<ChatCubit>(
          create: (_) => sl<ChatCubit>()..loadChats(),
        ),
        BlocProvider<CustomizerCubit>(
          create: (_) => sl<CustomizerCubit>(),
        ),
        BlocProvider<AdminNotificationCubit>(
          create: (_) => sl<AdminNotificationCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) => previous.runtimeType != current.runtimeType,
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.read<NotificationCubit>().connect();
                context.read<AdminNotificationCubit>().connect();
                context.read<ChatCubit>().connect();
              } else if (state is AuthUnauthenticated) {
                context.read<NotificationCubit>().disconnect();
                context.read<AdminNotificationCubit>().disconnect();
                context.read<ChatCubit>().disconnect();
              }
            },
            child: BlocListener<AdminNotificationCubit, AdminNotificationState>(
              listenWhen: (previous, current) =>
                  previous.latestNotification != current.latestNotification &&
                  current.latestNotification != null,
              listener: (context, state) {
                final notification = state.latestNotification!;
                sl<NotificationService>().showNotification(
                  id: notification.orderId,
                  title: notification.title.isNotEmpty ? notification.title : 'New Notification: #${notification.orderId}',
                  body: notification.message,
                  payload: '/admin/orders/${notification.orderId}',
                );
              },
              child: MaterialApp.router(
                title: AppConstants.appName,
                theme: AppTheme.light(),
                darkTheme: AppTheme.dark(),
                themeMode: themeMode,
                routerConfig: AppRouter.router,
                debugShowCheckedModeBanner: false,
              ),
            ),
          );
        },
      ),
    );
  }
}
