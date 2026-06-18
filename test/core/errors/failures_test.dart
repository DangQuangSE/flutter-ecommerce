import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';

void main() {
  group('NetworkFailure', () {
    test('stores message and statusCode', () {
      const f = NetworkFailure('Network error', statusCode: 404);
      expect(f.message, 'Network error');
      expect(f.statusCode, 404);
    });

    test('props includes statusCode when present', () {
      const f = NetworkFailure('err', statusCode: 500);
      expect(f.props, ['err', 500]);
    });

    test('props uses 0 as default when statusCode is null', () {
      const f = NetworkFailure('err');
      expect(f.props, ['err', 0]);
    });

    test('two NetworkFailures with same values are equal', () {
      const a = NetworkFailure('err', statusCode: 400);
      const b = NetworkFailure('err', statusCode: 400);
      expect(a, equals(b));
    });
  });

  group('ParseFailure', () {
    test('stores message', () {
      const f = ParseFailure('parse error');
      expect(f.message, 'parse error');
    });

    test('props includes message', () {
      const f = ParseFailure('parse error');
      expect(f.props, ['parse error']);
    });
  });

  group('CacheFailure', () {
    test('stores message', () {
      const f = CacheFailure('cache miss');
      expect(f.message, 'cache miss');
    });

    test('props includes message', () {
      const f = CacheFailure('cache miss');
      expect(f.props, ['cache miss']);
    });
  });

  group('DomainFailure', () {
    test('stores message', () {
      const f = DomainFailure('domain error');
      expect(f.message, 'domain error');
    });

    test('props includes message', () {
      const f = DomainFailure('domain error');
      expect(f.props, ['domain error']);
    });
  });

  group('AuthFailure', () {
    test('stores message', () {
      const f = AuthFailure('unauthorized');
      expect(f.message, 'unauthorized');
    });

    test('props includes message', () {
      const f = AuthFailure('unauthorized');
      expect(f.props, ['unauthorized']);
    });

    test('two AuthFailures with same message are equal', () {
      const a = AuthFailure('token expired');
      const b = AuthFailure('token expired');
      expect(a, equals(b));
    });
  });
}
