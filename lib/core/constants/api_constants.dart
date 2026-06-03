abstract final class ApiConstants {
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String login = '/api/auth/login';
  static const String me = '/api/auth/me';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String registerRequestOtp = '/api/auth/register/request-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String register = '/api/auth/register';
  static const String resendOtp = '/api/auth/resend-otp';

  // TODO: align with backend when product/cart APIs are wired
  static const String products = '/products';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Admin Product
  static const String adminProducts = '/api/admin/products';
  static String adminProductById(int id) => '/api/admin/products/$id';
  static String adminProductVariants(int productId) =>
      '/api/admin/products/$productId/variants';
  static String adminProductImages(int productId) =>
      '/api/admin/products/$productId/images';

  // Admin Variant / Image (standalone)
  static String adminVariantById(int variantId) =>
      '/api/admin/product-variants/$variantId';
  static String adminImageById(int imageId) =>
      '/api/admin/product-images/$imageId';
}
