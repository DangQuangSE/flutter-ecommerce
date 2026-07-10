import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_ecommerce/core/network/dio_client.dart';
import 'package:flutter_ecommerce/core/storage/app_settings_storage.dart';
import 'package:flutter_ecommerce/core/storage/auth_token_storage.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/app/theme/theme_cubit.dart';
import 'package:flutter_ecommerce/core/utils/notification_service.dart';
import 'package:flutter_ecommerce/features/address/address_module.dart';
import 'package:flutter_ecommerce/features/admin/admin_module.dart';
import 'package:flutter_ecommerce/features/admin/product/admin_product_module.dart';
import 'package:flutter_ecommerce/features/auth/auth_module.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_ecommerce/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_ecommerce/features/brand/brand_module.dart';
import 'package:flutter_ecommerce/features/cart/cart_module.dart';
import 'package:flutter_ecommerce/features/category/category_module.dart';
import 'package:flutter_ecommerce/features/chat/chat_module.dart';
import 'package:flutter_ecommerce/features/checkout/checkout_module.dart';
import 'package:flutter_ecommerce/features/color/color_module.dart';
import 'package:flutter_ecommerce/features/coupon/coupon_module.dart';
import 'package:flutter_ecommerce/features/customizer/customizer_module.dart';
import 'package:flutter_ecommerce/features/geo/geo_module.dart';
import 'package:flutter_ecommerce/features/location/location_module.dart';
import 'package:flutter_ecommerce/features/notification/notification_module.dart';
import 'package:flutter_ecommerce/features/order/order_module.dart';
import 'package:flutter_ecommerce/features/product/product_module.dart';
import 'package:flutter_ecommerce/features/profile/profile_module.dart';
import 'package:flutter_ecommerce/features/review/review_module.dart';
import 'package:flutter_ecommerce/features/setting/setting_module.dart';
import 'package:flutter_ecommerce/features/shop/shop_module.dart';
import 'package:flutter_ecommerce/features/size/size_module.dart';

final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<LocalStorage>(
    () => LocalStorage(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<AuthTokenStorage>(
    () => AuthTokenStorage(sl<LocalStorage>()),
  );
  sl.registerLazySingleton<AppSettingsStorage>(
    () => AppSettingsStorage(sl<LocalStorage>()),
  );
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl<AppSettingsStorage>()));

  final CookieJar cookieJar;
  if (kIsWeb) {
    cookieJar = CookieJar();
  } else {
    final appDocDir = await getApplicationDocumentsDirectory();
    cookieJar = PersistCookieJar(
      storage: FileStorage('${appDocDir.path}/.cookies/'),
    );
  }
  sl.registerSingleton<CookieJar>(cookieJar);

  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      authTokenStorage: sl<AuthTokenStorage>(),
      cookieJar: sl<CookieJar>(),
      onSessionExpired: () async {
        if (sl.isRegistered<AuthBloc>()) {
          sl<AuthBloc>().add(const AuthLogoutRequested());
        }
      },
    ),
  );

  sl.registerLazySingleton<NotificationService>(
    () => NotificationService(),
  );

  setupAuthModule(sl);
  setupProductModule(sl);
  setupCustomizerModule(sl);
  setupAdminModule(sl);
  setupSizeModule(sl);
  setupBrandModule(sl);
  setupSettingModule(sl);
  setupReviewModule(sl);
  setupColorModule(sl);
  setupCategoryModule(sl);
  setupCouponModule(sl);
  setupCartModule(sl);
  setupProfileModule(sl);
  setupShopModule(sl);
  setupGeoModule(sl);
  setupNotificationModule(sl);
  setupChatModule(sl);
  setupCheckoutModule(sl);
  setupOrderModule(sl);
  setupAddressModule(sl);
  setupLocationModule(sl);
  setupAdminProductModule(sl);
}
