import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_order_detail_page.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_order_list_page.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/design_viewer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/design_viewer_page.dart';

List<RouteBase> adminOrderRoutes() {
  return [
    GoRoute(
      path: '/admin/orders',
      name: AppRoutes.adminOrders,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AdminOrderCubit>()..loadOrders(),
        child: const AdminOrderListPage(),
      ),
      routes: [
        GoRoute(
          path: ':orderId',
          name: AppRoutes.adminOrderDetail,
          builder: (context, state) {
            final orderId = state.pathParameters['orderId'] ?? '';
            return BlocProvider(
              create: (_) => sl<AdminOrderCubit>()
                ..loadOrderDetail(int.tryParse(orderId) ?? 0),
              child: AdminOrderDetailPage(orderId: orderId),
            );
          },
          routes: [
            GoRoute(
              path: 'design/:designId',
              name: AppRoutes.adminOrderDesignViewer,
              builder: (context, state) {
                final id =
                    int.tryParse(state.pathParameters['designId'] ?? '');
                if (id == null || id <= 0) {
                  return const Scaffold(
                    body: Center(
                      child: Text(AppStrings.designViewerInvalidId),
                    ),
                  );
                }
                return BlocProvider(
                  create: (_) =>
                      sl<DesignViewerCubit>()..load(id, DesignViewerRole.admin),
                  child: DesignViewerPage(
                    designId: id,
                    role: DesignViewerRole.admin,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
  ];
}
