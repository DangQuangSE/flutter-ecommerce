import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/bloc/admin_product_list_bloc.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_detail_page.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_form_page.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_list_page.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_event.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_order_detail_page.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_order_list_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/brand/presentation/cubit/brand_cubit.dart';
import 'package:flutter_ecommerce/features/brand/presentation/pages/brand_management_page.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';
import 'package:flutter_ecommerce/features/category/presentation/models/category_form_extra.dart';
import 'package:flutter_ecommerce/features/category/presentation/pages/category_form_page.dart';
import 'package:flutter_ecommerce/features/category/presentation/pages/category_management_page.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/printing_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/pages/color_management_page.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/models/coupon_form_extra.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/pages/coupon_form_page.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/pages/coupon_management_page.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/design_viewer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/design_viewer_page.dart';
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

List<RouteBase> adminRoutes() {
  return [
    // Admin Dashboard Route
    GoRoute(
      path: '/admin',
      name: AppRoutes.adminDashboard,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<AdminBloc>()..add(const AdminStatsRequested()),
        child: const AdminDashboardPage(),
      ),
    ),
    GoRoute(
      path: '/admin/brands',
      name: AppRoutes.adminBrands,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<BrandCubit>()..loadBrands(),
        child: const BrandManagementPage(),
      ),
    ),
    GoRoute(
      path: '/admin/settings',
      name: AppRoutes.adminSiteSettings,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<SiteSettingCubit>()..loadSettings(),
        child: const AdminSiteSettingPage(),
      ),
    ),
    GoRoute(
      path: '/admin/colors',
      name: AppRoutes.adminColors,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<ProductColorCubit>()..loadColors()),
          BlocProvider(create: (_) => sl<PrintingColorCubit>()..loadColors()),
        ],
        child: const ColorManagementPage(),
      ),
    ),
    GoRoute(
      path: '/admin/categories',
      name: AppRoutes.adminCategories,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CategoryCubit>(),
        child: const CategoryManagementPage(),
      ),
      routes: [
        GoRoute(
          path: 'form',
          name: AppRoutes.adminCategoryForm,
          builder: (context, state) {
            final extra = state.extra as CategoryFormExtra?;
            if (extra == null) {
              return BlocProvider(
                create: (_) => sl<CategoryCubit>(),
                child: const CategoryManagementPage(),
              );
            }
            return BlocProvider.value(
              value: extra.cubit,
              child: CategoryFormPage(
                category: extra.category,
                parents: extra.parents,
              ),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/admin/coupons',
      name: AppRoutes.adminCoupons,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<CouponCubit>(),
        child: const CouponManagementPage(),
      ),
      routes: [
        GoRoute(
          path: 'form',
          name: AppRoutes.adminCouponForm,
          builder: (context, state) {
            final extra = state.extra as CouponFormExtra?;
            if (extra == null) {
              return BlocProvider(
                create: (_) => sl<CouponCubit>(),
                child: const CouponManagementPage(),
              );
            }
            return BlocProvider.value(
              value: extra.cubit,
              child: CouponFormPage(coupon: extra.coupon),
            );
          },
        ),
      ],
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

    // ── Admin Product ──────────────────────────────────────────────────────
    GoRoute(
      path: '/admin/products',
      name: AppRoutes.adminProductList,
      redirect: (context, routerState) {
        final authState = sl<AuthBloc>().state;
        if (authState is! AuthAuthenticated) return '/login';
        if (authState.user.role != 'ADMIN') return '/';
        return null;
      },
      builder: (context, state) => BlocProvider(
        create: (_) =>
            sl<AdminProductListBloc>()..add(AdminProductListLoaded()),
        child: const AdminProductListPage(),
      ),
      routes: [
        GoRoute(
          path: 'create',
          name: AppRoutes.adminProductCreate,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => sl<AdminProductFormCubit>()..loadDropdowns()),
              BlocProvider(create: (_) => sl<AdminProductVariantCubit>()),
              BlocProvider(create: (_) => sl<AdminProductImageCubit>()),
              BlocProvider(
                  create: (_) => sl<ProductColorCubit>()..loadColors()),
            ],
            child: const AdminProductFormPage(),
          ),
        ),
        GoRoute(
          path: ':id',
          name: AppRoutes.adminProductDetail,
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');
            if (id == null) {
              return const Scaffold(
                body: Center(
                  child: Text('ID sản phẩm không hợp lệ'),
                ),
              );
            }
            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) =>
                      sl<AdminProductDetailCubit>()..loadDetail(id),
                ),
                BlocProvider(create: (_) => sl<AdminProductVariantCubit>()),
                BlocProvider(create: (_) => sl<AdminProductImageCubit>()),
                BlocProvider(
                    create: (_) => sl<SizeGroupCubit>()..loadSizeGroups()),
                BlocProvider(
                    create: (_) => sl<ProductColorCubit>()..loadColors()),
              ],
              child: AdminProductDetailPage(productId: id),
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: AppRoutes.adminProductEdit,
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) {
                  return const Scaffold(
                    body: Center(
                      child: Text('ID sản phẩm không hợp lệ'),
                    ),
                  );
                }
                return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (_) =>
                          sl<AdminProductDetailCubit>()..loadDetail(id),
                    ),
                    BlocProvider(
                      create: (_) => sl<AdminProductFormCubit>()
                        ..loadDropdowns()
                        ..beginEditMode(),
                    ),
                    BlocProvider(
                        create: (_) => sl<AdminProductVariantCubit>()),
                    BlocProvider(
                        create: (_) => sl<AdminProductImageCubit>()),
                    BlocProvider(
                        create: (_) =>
                            sl<ProductColorCubit>()..loadColors()),
                  ],
                  child: AdminProductFormPage(productId: id),
                );
              },
            ),
          ],
        ),
      ],
    ),

    // ── Admin shop config ─────────────────────────────────────────────────
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
