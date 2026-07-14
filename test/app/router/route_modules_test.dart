import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_ecommerce/app/router/auth_routes.dart';
import 'package:flutter_ecommerce/app/router/admin_routes.dart';
import 'package:flutter_ecommerce/app/router/customer_routes.dart';

void main() {
  group('authRoutes', () {
    late List<RouteBase> routes;

    setUp(() {
      routes = authRoutes();
    });

    test('returns a non-empty list of routes', () {
      expect(routes, isNotEmpty);
    });

    test('includes /splash route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/splash'));
    });

    test('includes /login route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/login'));
    });

    test('includes /register route with nested otp and password', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/register'));
      expect(paths, contains('/register/otp'));
      expect(paths, contains('/register/password'));
    });

    test('includes /forgot-password route with nested otp and reset', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/forgot-password'));
      expect(paths, contains('/forgot-password/otp'));
      expect(paths, contains('/forgot-password/reset'));
    });

    test('all named routes have names assigned', () {
      final namedCount = _countNamedRoutes(routes);
      expect(namedCount, greaterThan(0));
    });
  });

  group('adminRoutes', () {
    late List<RouteBase> routes;

    setUp(() {
      routes = adminRoutes();
    });

    test('returns a non-empty list of routes', () {
      expect(routes, isNotEmpty);
    });

    test('includes /admin dashboard route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin'));
    });

    test('includes /admin/products and sub-routes', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/products'));
      expect(paths, contains('/admin/products/create'));
      expect(paths, contains('/admin/products/:id'));
      expect(paths, contains('/admin/products/:id/edit'));
    });

    test('includes /admin/brands route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/brands'));
    });

    test('includes /admin/categories with form sub-route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/categories'));
      expect(paths, contains('/admin/categories/form'));
    });

    test('includes /admin/coupons with form sub-route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/coupons'));
      expect(paths, contains('/admin/coupons/form'));
    });

    test('includes /admin/orders with detail and design viewer', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/orders'));
      expect(paths, contains('/admin/orders/:orderId'));
      expect(paths, contains('/admin/orders/:orderId/design/:designId'));
    });

    test('includes /admin/size-groups with create and edit', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/size-groups'));
      expect(paths, contains('/admin/size-groups/create'));
      expect(paths, contains('/admin/size-groups/:id/edit'));
    });

    test('includes /admin/shop-config route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/shop-config'));
    });

    test('includes /admin/reviews route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/reviews'));
    });

    test('includes /admin/settings route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/settings'));
    });

    test('includes /admin/colors route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/admin/colors'));
    });
  });

  group('customerRoutes', () {
    late List<RouteBase> routes;

    setUp(() {
      routes = customerRoutes();
    });

    test('returns a non-empty list of routes', () {
      expect(routes, isNotEmpty);
    });

    test('includes /home route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/home'));
    });

    test('includes /products and /products/:productId', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/products'));
      expect(paths, contains('/products/:productId'));
    });

    test('includes /cart route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/cart'));
    });

    test('includes /checkout with success sub-route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/checkout'));
      expect(paths, contains('/checkout/success'));
    });

    test('includes /payment/vnpay and /payment/result', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/payment/vnpay'));
      expect(paths, contains('/payment/result'));
    });

    test('includes /orders with detail, design viewer, and write review', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/orders'));
      expect(paths, contains('/orders/:orderId'));
      expect(paths, contains('/orders/:orderId/design/:designId'));
      expect(paths, contains('/orders/:orderId/write-review'));
    });

    test('includes /profile with edit sub-route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/profile'));
      expect(paths, contains('/profile/edit'));
    });

    test('includes /addresses with form sub-route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/addresses'));
      expect(paths, contains('/addresses/form'));
    });

    test('includes /chats with /chats/:chatId', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/chats'));
      expect(paths, contains('/chats/:chatId'));
    });

    test('includes /customizer/:productId route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/customizer/:productId'));
    });

    test('includes /shop route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/shop'));
    });

    test('includes /notifications route', () {
      final paths = _extractFullPaths(routes);
      expect(paths, contains('/notifications'));
    });
  });
}

/// Recursively extracts full paths by accumulating parent paths.
List<String> _extractFullPaths(
  List<RouteBase> routes, [
  String parent = '',
]) {
  final paths = <String>[];
  for (final route in routes) {
    if (route is GoRoute) {
      final fullPath = parent.isEmpty
          ? route.path
          : '${parent.startsWith('/') ? '' : '/'}$parent/${route.path}';
      // Normalize: ensure leading slash, remove double slashes
      final normalized = '/' + fullPath.split('/').where((s) => s.isNotEmpty).join('/');
      paths.add(normalized);
      if (route.routes.isNotEmpty) {
        paths.addAll(_extractFullPaths(route.routes, normalized));
      }
    } else if (route is ShellRoute) {
      for (final child in route.routes) {
        if (child is GoRoute) {
          final fullPath = parent.isEmpty
              ? child.path
              : '${parent.startsWith('/') ? '' : '/'}$parent/${child.path}';
          final normalized = '/' + fullPath.split('/').where((s) => s.isNotEmpty).join('/');
          paths.add(normalized);
          if (child.routes.isNotEmpty) {
            paths.addAll(_extractFullPaths(child.routes, normalized));
          }
        }
      }
    }
  }
  return paths;
}

int _countNamedRoutes(List<RouteBase> routes) {
  int count = 0;
  for (final route in routes) {
    if (route is GoRoute) {
      if (route.name != null) count++;
      count += _countNamedRoutes(route.routes);
    } else if (route is ShellRoute) {
      count += _countNamedRoutes(route.routes);
    }
  }
  return count;
}
