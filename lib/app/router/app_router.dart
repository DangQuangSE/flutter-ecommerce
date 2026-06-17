import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/bloc/forgot_password_bloc.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/models/forgot_password_otp_extra.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/models/forgot_password_reset_extra.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/pages/forgot_password_email_page.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/pages/forgot_password_otp_page.dart';
import 'package:flutter_ecommerce/features/auth/forgot_password/presentation/pages/forgot_password_reset_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/register_password_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_otp_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/models/register_password_extra.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/splash_page.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_ecommerce/features/notification/presentation/pages/notification_page.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/pages/checkout_success_page.dart';
import 'package:flutter_ecommerce/features/payment/presentation/models/vnpay_payment_extra.dart';
import 'package:flutter_ecommerce/features/payment/presentation/pages/payment_result_page.dart';
import 'package:flutter_ecommerce/features/payment/presentation/pages/vnpay_payment_page.dart';
import 'package:flutter_ecommerce/features/order/presentation/pages/order_detail_page.dart';
import 'package:flutter_ecommerce/features/order/presentation/pages/order_list_page.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_list_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_catalog_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/home_page.dart';
import 'package:flutter_ecommerce/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_ecommerce/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_ecommerce/features/chat/presentation/pages/chat_list_page.dart';
import 'package:flutter_ecommerce/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/customizer_page.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/bloc/admin_product_list_bloc.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_detail_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_form_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_variant_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/cubit/admin_product_image_cubit.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_list_page.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_detail_page.dart';
import 'package:flutter_ecommerce/features/admin/product/presentation/pages/admin_product_form_page.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_bloc.dart';
import 'package:flutter_ecommerce/features/admin/presentation/bloc/admin_event.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_order_list_page.dart';
import 'package:flutter_ecommerce/features/admin/presentation/pages/admin_order_detail_page.dart';
import 'package:flutter_ecommerce/features/admin/presentation/cubit/admin_order_cubit.dart';
import 'package:flutter_ecommerce/features/brand/presentation/cubit/brand_cubit.dart';
import 'package:flutter_ecommerce/features/brand/presentation/pages/brand_management_page.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';
import 'package:flutter_ecommerce/features/setting/presentation/pages/admin_site_setting_page.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/product_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/cubit/printing_color_cubit.dart';
import 'package:flutter_ecommerce/features/color/presentation/pages/color_management_page.dart';
import 'package:flutter_ecommerce/features/category/presentation/cubit/category_cubit.dart';
import 'package:flutter_ecommerce/features/category/presentation/pages/category_management_page.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/pages/coupon_management_page.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/admin_review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/pages/admin_review_list_page.dart';
import 'package:flutter_ecommerce/features/size/domain/entities/size_group_entity.dart';
import 'package:flutter_ecommerce/features/size/presentation/cubit/size_group_cubit.dart';
import 'package:flutter_ecommerce/features/size/presentation/pages/admin_size_group_list_page.dart';
import 'package:flutter_ecommerce/features/size/presentation/pages/admin_size_group_form_page.dart';

/// GoRouterRefreshStream was removed from go_router 5+; implement manually.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

RegisterOtpExtra? _resolveRegisterOtpExtra(GoRouterState state) {
  if (state.extra is RegisterOtpExtra) {
    return state.extra as RegisterOtpExtra;
  }
  return switch (sl<AuthBloc>().state) {
    AuthOtpSent(:final email) => RegisterOtpExtra(email: email),
    AuthRegisterOtpError(:final email) => RegisterOtpExtra(email: email),
    _ => null,
  };
}

RegisterPasswordExtra? _resolveRegisterPasswordExtra(GoRouterState state) {
  if (state.extra is RegisterPasswordExtra) {
    return state.extra as RegisterPasswordExtra;
  }
  return switch (sl<AuthBloc>().state) {
    AuthOtpVerified(:final email) => RegisterPasswordExtra(email: email),
    _ => null,
  };
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: kDebugMode,
    // Wired to the AuthBloc singleton — router re-evaluates on every auth state change
    refreshListenable: GoRouterRefreshStream(sl<AuthBloc>().stream),
    redirect: (BuildContext context, GoRouterState state) {
      final path = state.uri.path;
      final isForgotPasswordFlow = path.startsWith('/forgot-password');
      final isGoingToAuth = path == '/login' ||
          path == '/register' ||
          path == '/register/otp' ||
          path == '/register/password' ||
          path == '/splash' ||
          isForgotPasswordFlow;

      final authState = sl<AuthBloc>().state;
      if (authState is AuthRegistrationSuccess) {
        if (path.startsWith('/register')) return '/login';
        return null;
      }
      if (authState is AuthOtpVerified && path == '/register/otp') {
        return '/register/password';
      }
      if (authState is AuthOtpSent ||
          authState is AuthRegisterOtpError ||
          authState is AuthOtpVerified) {
        return null;
      }

      final isAuthenticated = authState is AuthAuthenticated;

      if (!isAuthenticated && !isGoingToAuth) return '/login';

      if (isAuthenticated) {
        final user = (authState as AuthAuthenticated).user;
        if (isForgotPasswordFlow) {
          return user.isAdmin ? '/admin' : '/home';
        }
        if (user.isAdmin) {
          if (isGoingToAuth || path == '/home') return '/admin';
        } else {
          if (isGoingToAuth) return '/home';
          if (path.startsWith('/admin')) return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
        routes: [
          GoRoute(
            path: 'otp',
            name: AppRoutes.registerOtp,
            redirect: (context, state) {
              final authState = sl<AuthBloc>().state;
              if (authState is AuthOtpVerified) {
                return '/register/password';
              }
              if (state.extra is RegisterOtpExtra) return null;
              if (authState is AuthOtpSent ||
                  authState is AuthRegisterOtpError) {
                return null;
              }
              return '/register';
            },
            builder: (context, state) {
              final extra = _resolveRegisterOtpExtra(state);
              if (extra == null) return const RegisterPage();
              return OtpVerificationPage(extra: extra);
            },
          ),
          GoRoute(
            path: 'password',
            name: AppRoutes.registerPassword,
            redirect: (context, state) {
              final authState = sl<AuthBloc>().state;
              if (authState is AuthRegistrationSuccess) return '/login';
              if (authState is AuthOtpVerified) return null;
              if (state.extra is RegisterPasswordExtra) return null;
              return '/register';
            },
            builder: (context, state) {
              final extra = _resolveRegisterPasswordExtra(state);
              if (extra == null) return const RegisterPage();
              return RegisterPasswordPage(extra: extra);
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => BlocProvider(
          create: (_) => sl<ForgotPasswordBloc>(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/forgot-password',
            name: AppRoutes.forgotPassword,
            builder: (context, state) => const ForgotPasswordEmailPage(),
            routes: [
              GoRoute(
                path: 'otp',
                name: AppRoutes.forgotPasswordOtp,
                redirect: (context, state) {
                  if (state.extra is! ForgotPasswordOtpExtra) {
                    return '/forgot-password';
                  }
                  return null;
                },
                builder: (context, state) {
                  final extra = state.extra! as ForgotPasswordOtpExtra;
                  return ForgotPasswordOtpPage(extra: extra);
                },
              ),
              GoRoute(
                path: 'reset',
                name: AppRoutes.forgotPasswordReset,
                redirect: (context, state) {
                  if (state.extra is! ForgotPasswordResetExtra) {
                    return '/forgot-password';
                  }
                  return null;
                },
                builder: (context, state) {
                  final extra = state.extra! as ForgotPasswordResetExtra;
                  return ForgotPasswordResetPage(extra: extra);
                },
              ),
            ],
          ),
        ],
      ),

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
      ),
      GoRoute(
        path: '/admin/coupons',
        name: AppRoutes.adminCoupons,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CouponCubit>(),
          child: const CouponManagementPage(),
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

      // Home route (main screen after login)
      GoRoute(
        path: '/home',
        name: AppRoutes.home,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProductBloc>(),
          child: const HomePage(),
        ),
      ),

      GoRoute(
        path: '/products',
        name: AppRoutes.productList,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProductCatalogBloc>()..add(ProductCatalogFetch()),
          child: const ProductCatalogPage(),
        ),
        routes: [
          GoRoute(
            path: ':productId',
            name: AppRoutes.productDetail,
            builder: (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => sl<ProductBloc>()),
                BlocProvider(create: (_) => sl<SiteSettingCubit>()),
                BlocProvider(create: (_) => sl<ReviewCubit>()),
              ],
              child: ProductDetailPage(
                productId: state.pathParameters['productId'] ?? '',
              ),
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/cart',
        name: AppRoutes.cart,
        builder: (context, state) => const CartPage(),
      ),

      GoRoute(
        path: '/notifications',
        name: AppRoutes.notificationList,
        builder: (context, state) => const NotificationPage(),
      ),

      GoRoute(
        path: '/checkout',
        name: AppRoutes.checkout,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CheckoutBloc>(),
          child: CheckoutPage(cartItemIds: state.extra as List<int>?),
        ),
        routes: [
          GoRoute(
            path: 'success',
            name: AppRoutes.checkoutSuccess,
            builder: (context, state) => const CheckoutSuccessPage(),
          ),
        ],
      ),

      GoRoute(
        path: '/payment/vnpay',
        name: AppRoutes.vnpayPayment,
        builder: (context, state) {
          final extra = state.extra! as VnpayPaymentExtra;
          return VnpayPaymentPage(extra: extra);
        },
      ),

      GoRoute(
        path: '/payment/result',
        name: AppRoutes.paymentResult,
        builder: (context, state) {
          final extra = state.extra! as Map<String, dynamic>;
          return PaymentResultPage(
            success: extra['success'] as bool? ?? false,
            message: extra['message'] as String? ?? '',
          );
        },
      ),

      GoRoute(
        path: '/orders',
        name: AppRoutes.orderList,
        builder: (context, state) => const OrderListPage(),
        routes: [
          GoRoute(
            path: ':orderId',
            name: AppRoutes.orderDetail,
            builder: (context, state) => OrderDetailPage(
              orderId: state.pathParameters['orderId'] ?? '',
            ),
          ),
        ],
      ),

      GoRoute(
        path: '/profile',
        name: AppRoutes.profile,
        builder: (context, state) => const ProfilePage(),
        routes: [
          GoRoute(
            path: 'edit',
            name: AppRoutes.editProfile,
            builder: (context, state) => const EditProfilePage(),
          ),
        ],
      ),
      GoRoute(
        path: '/chats',
        name: AppRoutes.chatList,
        builder: (context, state) => const ChatListPage(),
        routes: [
          GoRoute(
            path: ':chatId',
            name: AppRoutes.chatDetail,
            builder: (context, state) => ChatDetailPage(
              chatId: state.pathParameters['chatId'] ?? '',
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/customizer/:productId',
        name: AppRoutes.productCustomizer,
        builder: (context, state) {
          final variantIdStr = state.uri.queryParameters['variantId'];
          final quantityStr = state.uri.queryParameters['quantity'];
          final priceStr = state.uri.queryParameters['price'];
          final itemIdStr = state.uri.queryParameters['itemId'];
          final customDesignIdStr = state.uri.queryParameters['customDesignId'];

          final variantId =
              variantIdStr != null ? int.tryParse(variantIdStr) : null;
          final cartQuantity = int.tryParse(quantityStr ?? '') ?? 1;
          final basePrice = priceStr != null ? double.tryParse(priceStr) : null;
          final itemId = itemIdStr != null ? int.tryParse(itemIdStr) : null;
          final customDesignId =
              (customDesignIdStr != null && customDesignIdStr.isNotEmpty)
                  ? int.tryParse(customDesignIdStr)
                  : null;

          return CustomizerPage(
            productId: state.pathParameters['productId'] ?? '',
            productName: state.uri.queryParameters['name'] ?? 'AeroTech Tee',
            variantId: variantId,
            cartQuantity: cartQuantity,
            basePrice: basePrice,
            customDesignId: customDesignId,
            onConfirm: variantId == null
                ? null
                : (newCustomDesignId) {
                    if (itemId != null) {
                      return sl<CartCubit>().replaceCartItemDesign(
                        itemId: itemId,
                        variantId: variantId,
                        quantity: cartQuantity,
                        newCustomDesignId: newCustomDesignId,
                      );
                    } else {
                      return sl<CartCubit>().replaceWithCustomDesign(
                        variantId: variantId,
                        quantity: cartQuantity,
                        customDesignId: newCustomDesignId,
                      );
                    }
                  },
          );
        },
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
                    create: (_) =>
                        sl<AdminProductFormCubit>()..loadDropdowns()),
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
                    body: Center(child: Text('ID sản phẩm không hợp lệ')));
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
                        body: Center(child: Text('ID sản phẩm không hợp lệ')));
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
                            ..beginEditMode()),
                      BlocProvider(
                          create: (_) => sl<AdminProductVariantCubit>()),
                      BlocProvider(create: (_) => sl<AdminProductImageCubit>()),
                      BlocProvider(
                          create: (_) => sl<ProductColorCubit>()..loadColors()),
                    ],
                    child: AdminProductFormPage(productId: id),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error?.message}')),
    ),
  );
}
