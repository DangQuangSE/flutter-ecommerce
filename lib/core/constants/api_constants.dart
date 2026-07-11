import 'package:flutter/foundation.dart';

abstract final class ApiConstants {
  /// Base URL of the Spring Boot backend, resolved per platform so the app
  /// reaches the dev host without a manual `--dart-define` on every run:
  /// - an explicit `--dart-define=BASE_URL=...` always wins (real device / staging)
  /// - Android emulator: `10.0.2.2` is its alias for the host machine
  /// - iOS simulator / macOS / web: reach the host directly via localhost
  static String get baseUrl {
    const override = String.fromEnvironment('BASE_URL');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return 'http://127.0.0.1:8080';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String registerRequestOtp = '/api/auth/register/request-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String register = '/api/auth/register';
  static const String resendOtp = '/api/auth/resend-otp';

  // Forgot password — verify body uses `otpCode` (not register's `otp`).
  // request-otp: { email } → message (neutral), data: null
  // verify-otp: { email, otpCode } → data: { message, forgotPasswordToken }
  // reset: { forgotPasswordToken, newPassword }
  static const String forgotPasswordRequestOtp =
      '/api/forgot-password/request-otp';
  static const String forgotPasswordVerifyOtp =
      '/api/forgot-password/verify-otp';
  static const String forgotPasswordReset = '/api/forgot-password/reset';
  static const String brands = '/api/brands';
  static const String adminBrands = '/api/admin/brands';

  static const String colors = '/api/colors';
  static const String adminColors = '/api/admin/colors';

  static const String printingColors = '/api/public/printing/colors';
  static const String printingAll = '/api/public/printing/all';
  static const String adminPrintingColors = '/api/admin/printing/colors';

  // Categories — public reads + admin writes
  static const String categories = '/api/categories';
  static const String adminCategories = '/api/admin/categories';

  // Coupons — admin only (requires ADMIN role)
  static const String adminCoupons = '/api/v1/admin/coupons';
  static const String publicCoupons = '/api/v1/coupons';

  // Chat — any authenticated user (USER: own conversations, ADMIN: support inbox)
  static const String chatConversations = '/api/chat/conversations';

  // TODO: align with backend when product/cart APIs are wired
  static const String products = '/api/products';
  static const String cart = '/api/carts/me';
  static const String orders = '/api/v1/orders';
  static const String vnpayCreate = '/api/v1/payments/vnpay/create';
  static String vnpayVerify(int orderId) =>
      '/api/v1/payments/vnpay/verify/$orderId';
  static const String adminOrders = '/api/v1/admin/orders';
  static const String profile = '/profile';

  // User profile (current user)
  static const String profileMe = '/api/profiles/me';
  static const String profileAvatar = '/api/profiles/me/avatar';

  static const String customDesigns = '/api/custom-designs';
  static String customDesignById(int id) => '/api/custom-designs/$id';
  static String adminCustomDesignById(int id) =>
      '/api/admin/custom-designs/$id';

  // Size Groups
  static const String sizeGroups = '/api/size-groups';
  static const String adminSizeGroups = '/api/admin/size-groups';
  static String adminSizeGroupById(int id) => '/api/admin/size-groups/$id';

  // Admin Product
  static const String adminProducts = '/api/admin/products';
  static String adminProductById(int id) => '/api/admin/products/$id';
  static String adminProductRestore(int id) =>
      '/api/admin/products/$id/restore';
  static String adminProductVariants(int productId) =>
      '/api/admin/products/$productId/variants';
  static String adminProductVariantsBatch(int productId) =>
      '/api/admin/products/$productId/variants/batch';
  static String adminProductImages(int productId) =>
      '/api/admin/products/$productId/images';

  // Admin Variant / Image (standalone)
  static String adminVariantById(int variantId) =>
      '/api/admin/product-variants/$variantId';
  static String adminImageById(int imageId) =>
      '/api/admin/product-images/$imageId';

  // Site Settings
  static const String settings = '/api/settings';
  static const String adminSettings = '/api/admin/settings';

  // Addresses
  static const String addresses = '/api/v1/addresses';

  // Reviews
  static String productReviews(int productId) =>
      '/api/public/reviews/product/$productId';

  // User Reviews — create/update a review for a delivered order item
  static const String userReviews = '/api/user/reviews';

  // Admin Reviews — view all + reply only (no hide/delete)
  static const String adminReviews = '/api/admin/reviews';
  static String adminReviewReply(int reviewId) =>
      '/api/admin/reviews/$reviewId/reply';

  // Shop profile
  static const String shop = '/api/shop';
  static const String adminShop = '/api/admin/shop';
  static const String adminShopUploadImage = '/api/admin/shop/upload-image';
}
