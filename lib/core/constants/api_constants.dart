abstract final class ApiConstants {
  static const String baseUrl = 'https://api.flutter-ecommerce.dev/v1';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
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
