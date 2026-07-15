import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/admin_review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/pages/admin_review_list_page.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';
import 'package:flutter_ecommerce/features/setting/presentation/pages/admin_site_setting_page.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:flutter_ecommerce/features/shop/presentation/pages/admin_shop_config_page.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/pages/admin_size_group_form_page.dart';
import 'package:flutter_ecommerce/features/size/presentation/pages/admin_size_group_list_page.dart';

List<RouteBase> adminConfigRoutes() {
  return [
    GoRoute(
      path: '/admin/settings',
      name: AppRoutes.adminSiteSettings,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SiteSettingCubit>()..loadSettings(),
        child: const AdminSiteSettingPage(),
      ),
    ),
    GoRoute(
      path: '/admin/reviews',
      name: AppRoutes.adminReviews,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AdminReviewCubit>(),
        child: const AdminReviewListPage(),
      ),
    ),
    GoRoute(
      path: '/admin/size-groups',
      name: AppRoutes.adminSizeGroups,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SizeGroupCubit>()..loadSizeGroups(),
        child: const AdminSizeGroupListPage(),
      ),
      routes: [
        GoRoute(
          path: 'create',
          name: AppRoutes.adminSizeGroupCreate,
          builder: (context, state) => BlocProvider(
            create: (_) => sl<SizeGroupCubit>(),
            child: const AdminSizeGroupFormPage(),
          ),
        ),
        GoRoute(
          path: ':id/edit',
          name: AppRoutes.adminSizeGroupEdit,
          builder: (context, state) {
            final group = state.extra as SizeGroupEntity?;
            return BlocProvider(
              create: (_) => sl<SizeGroupCubit>(),
              child: AdminSizeGroupFormPage(initialGroup: group),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/admin/shop-config',
      name: AppRoutes.adminShopConfig,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<ShopCubit>()..loadShop(),
        child: const AdminShopConfigPage(),
      ),
    ),
  ];
}
