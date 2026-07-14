import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/app_routes.dart';
import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/di/injection_container.dart';
import 'package:flutter_ecommerce/features/address/domain/entities/address_entity.dart';
import 'package:flutter_ecommerce/features/address/presentation/cubit/address_cubit.dart';
import 'package:flutter_ecommerce/features/address/presentation/pages/address_form_page.dart';
import 'package:flutter_ecommerce/features/address/presentation/pages/address_list_page.dart';
import 'package:flutter_ecommerce/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:flutter_ecommerce/features/cart/presentation/pages/cart_page.dart';
import 'package:flutter_ecommerce/features/chat/presentation/pages/chat_detail_page.dart';
import 'package:flutter_ecommerce/features/chat/presentation/pages/chat_entry_page.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/bloc/checkout_bloc.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/pages/checkout_page.dart';
import 'package:flutter_ecommerce/features/checkout/presentation/pages/checkout_success_page.dart';
import 'package:flutter_ecommerce/features/coupon/presentation/cubit/coupon_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/domain/entities/design_viewer_role.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/custom_design_spec_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/cubit/design_viewer_cubit.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/customizer_page.dart';
import 'package:flutter_ecommerce/features/customizer/presentation/pages/design_viewer_page.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/location/presentation/cubit/location_cubit.dart';
import 'package:flutter_ecommerce/features/notification/presentation/pages/notification_page.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_bloc.dart';
import 'package:flutter_ecommerce/features/order/presentation/bloc/order_event.dart';
import 'package:flutter_ecommerce/features/order/presentation/pages/order_detail_page.dart';
import 'package:flutter_ecommerce/features/order/presentation/pages/order_list_page.dart';
import 'package:flutter_ecommerce/features/payment/presentation/models/vnpay_payment_extra.dart';
import 'package:flutter_ecommerce/features/payment/presentation/pages/payment_result_page.dart';
import 'package:flutter_ecommerce/features/payment/presentation/pages/vnpay_payment_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/bloc/product_catalog_bloc.dart';
import 'package:flutter_ecommerce/features/product/presentation/cubit/product_filter_options_cubit.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/home_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_catalog_page.dart';
import 'package:flutter_ecommerce/features/product/presentation/pages/product_detail_page.dart';
import 'package:flutter_ecommerce/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:flutter_ecommerce/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_ecommerce/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/cubit/write_review_cubit.dart';
import 'package:flutter_ecommerce/features/review/presentation/pages/write_review_page.dart';
import 'package:flutter_ecommerce/features/setting/presentation/cubit/site_setting_cubit.dart';
import 'package:flutter_ecommerce/features/shop/presentation/cubit/shop_cubit.dart';
import 'package:flutter_ecommerce/features/shop/presentation/pages/shop_info_page.dart';

/// Fade-through page transition for bottom navigation tabs.
Page<void> _fadeThroughPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 260),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final scale = Tween<double>(begin: 0.985, end: 1).animate(fade);
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}

/// Slide-up page transition for detail screens.
Page<void> _slideUpPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.035),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
  );
}

List<RouteBase> customerRoutes() {
  return [
    // Home route (main screen after login)
    GoRoute(
      path: '/home',
      name: AppRoutes.home,
      pageBuilder: (context, state) => _fadeThroughPage(
        state: state,
        child: BlocProvider(
          create: (_) => sl<ProductBloc>(),
          child: const HomePage(),
        ),
      ),
    ),

    GoRoute(
      path: '/products',
      name: AppRoutes.productList,
      pageBuilder: (context, state) {
        // Home category tap passes {categoryId, categoryName} so the catalog
        // opens pre-filtered to that category.
        final extra = state.extra;
        final initialCategoryId =
            extra is Map ? extra['categoryId'] as int? : null;
        final initialCategoryName =
            extra is Map ? extra['categoryName'] as String? : null;
        return _fadeThroughPage(
          state: state,
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) {
                  final bloc = sl<ProductCatalogBloc>();
                  if (initialCategoryId != null) {
                    bloc.add(ProductCatalogFilterChanged(
                      categoryId: initialCategoryId,
                      categoryName: initialCategoryName,
                    ));
                  } else {
                    bloc.add(ProductCatalogFetch());
                  }
                  return bloc;
                },
              ),
              BlocProvider(create: (_) => sl<ProductFilterOptionsCubit>()),
            ],
            child: const ProductCatalogPage(),
          ),
        );
      },
      routes: [
        GoRoute(
          path: ':productId',
          name: AppRoutes.productDetail,
          pageBuilder: (context, state) => _slideUpPage(
            state: state,
            child: MultiBlocProvider(
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
        ),
      ],
    ),

    GoRoute(
      path: '/cart',
      name: AppRoutes.cart,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: BlocProvider(
          create: (_) => sl<CustomDesignSpecCubit>(),
          child: const CartPage(),
        ),
      ),
    ),

    GoRoute(
      path: '/notifications',
      name: AppRoutes.notificationList,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const NotificationPage(),
      ),
    ),

    GoRoute(
      path: '/checkout',
      name: AppRoutes.checkout,
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => sl<CheckoutBloc>()),
          BlocProvider(
              create: (_) => sl<CouponCubit>()..loadUserAvailableCoupons()),
          BlocProvider.value(value: sl<AddressCubit>()..loadAddresses()),
          BlocProvider(create: (_) => sl<CustomDesignSpecCubit>()),
        ],
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
      pageBuilder: (context, state) => _fadeThroughPage(
        state: state,
        child: BlocProvider(
          create: (_) => sl<OrderBloc>()..add(const OrderListRequested()),
          child: const OrderListPage(),
        ),
      ),
      routes: [
        GoRoute(
          path: ':orderId',
          name: AppRoutes.orderDetail,
          pageBuilder: (context, state) {
            final orderId = state.pathParameters['orderId'] ?? '';
            return _slideUpPage(
              state: state,
              child: BlocProvider(
                create: (_) => sl<OrderBloc>()
                  ..add(OrderDetailRequested(
                    int.tryParse(orderId) ?? 0,
                  )),
                child: OrderDetailPage(orderId: orderId),
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'design/:designId',
              name: AppRoutes.orderDesignViewer,
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
                      sl<DesignViewerCubit>()..load(id, DesignViewerRole.customer),
                  child: DesignViewerPage(
                    designId: id,
                    role: DesignViewerRole.customer,
                  ),
                );
              },
            ),
            GoRoute(
              path: 'write-review',
              name: AppRoutes.writeReview,
              builder: (context, state) {
                final args = state.extra! as WriteReviewArgs;
                return BlocProvider(
                  create: (_) => sl<WriteReviewCubit>(),
                  child: WriteReviewPage(args: args),
                );
              },
            ),
          ],
        ),
      ],
    ),

    GoRoute(
      path: '/profile',
      name: AppRoutes.profile,
      pageBuilder: (context, state) => _fadeThroughPage(
        state: state,
        child: BlocProvider.value(
          value: sl<ProfileCubit>()..loadProfile(),
          child: const ProfilePage(),
        ),
      ),
      routes: [
        GoRoute(
          path: 'edit',
          name: AppRoutes.editProfile,
          pageBuilder: (context, state) => _slideUpPage(
            state: state,
            child: BlocProvider.value(
              value: sl<ProfileCubit>()..loadProfile(),
              child: const EditProfilePage(),
            ),
          ),
        ),
      ],
    ),

    // ── Address Management ──────────────────────────────────────────────
    GoRoute(
      path: '/addresses',
      name: AppRoutes.addressList,
      builder: (context, state) => BlocProvider.value(
        value: sl<AddressCubit>()..loadAddresses(),
        child: const AddressListPage(),
      ),
      routes: [
        GoRoute(
          path: 'form',
          name: AppRoutes.addressForm,
          builder: (context, state) {
            final address = state.extra as AddressEntity?;
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: sl<AddressCubit>()),
                BlocProvider(create: (_) => sl<LocationCubit>()),
              ],
              child: AddressFormPage(initialAddress: address),
            );
          },
        ),
      ],
    ),

    GoRoute(
      path: '/chats',
      name: AppRoutes.chatList,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: const ChatEntryPage(),
      ),
      routes: [
        GoRoute(
          path: ':chatId',
          name: AppRoutes.chatDetail,
          pageBuilder: (context, state) => _slideUpPage(
            state: state,
            child: ChatDetailPage(
              chatId: state.pathParameters['chatId'] ?? '',
            ),
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
        final customDesignIdStr =
            state.uri.queryParameters['customDesignId'];

        final variantId =
            variantIdStr != null ? int.tryParse(variantIdStr) : null;
        final cartQuantity = int.tryParse(quantityStr ?? '') ?? 1;
        final basePrice =
            priceStr != null ? double.tryParse(priceStr) : null;
        final itemId =
            itemIdStr != null ? int.tryParse(itemIdStr) : null;
        final customDesignId =
            (customDesignIdStr != null && customDesignIdStr.isNotEmpty)
                ? int.tryParse(customDesignIdStr)
                : null;

        return CustomizerPage(
          productId: state.pathParameters['productId'] ?? '',
          productName:
              state.uri.queryParameters['name'] ?? 'AeroTech Tee',
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

    // ── Shop profile ──────────────────────────────────────────────────────
    GoRoute(
      path: '/shop',
      name: AppRoutes.shopInfo,
      pageBuilder: (context, state) => _slideUpPage(
        state: state,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => sl<ShopCubit>()..loadShop()),
            BlocProvider(create: (_) => sl<DirectionsCubit>()),
          ],
          child: const ShopInfoPage(),
        ),
      ),
    ),
  ];
}
