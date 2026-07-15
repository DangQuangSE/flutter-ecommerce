import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/bloc/admin_product_list_bloc.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_detail_page.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_form_page.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_list_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter/material.dart';

List<RouteBase> adminProductRoutes() {
  return [
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
  ];
}
