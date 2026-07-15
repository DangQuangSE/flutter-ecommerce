import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/admin_catalog_routes.dart';
import 'package:flutter_ecommerce/app/router/admin_config_routes.dart';
import 'package:flutter_ecommerce/app/router/admin_order_routes.dart';
import 'package:flutter_ecommerce/app/router/admin_product_routes.dart';
import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_event.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_dashboard_page.dart';

List<RouteBase> adminRoutes() {
  return [
    // Admin Dashboard
    GoRoute(
      path: '/admin',
      name: AppRoutes.adminDashboard,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AdminBloc>()..add(const AdminStatsRequested()),
        child: const AdminDashboardPage(),
      ),
    ),

    // Feature route groups
    ...adminCatalogRoutes(),
    ...adminOrderRoutes(),
    ...adminConfigRoutes(),
    ...adminProductRoutes(),
  ];
}
