import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
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

List<RouteBase> adminCatalogRoutes() {
  return [
    GoRoute(
      path: '/admin/brands',
      name: AppRoutes.adminBrands,
      builder: (context, state) => BlocProvider(
        create: (_) => sl<BrandCubit>()..loadBrands(),
        child: const BrandManagementPage(),
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
  ];
}
