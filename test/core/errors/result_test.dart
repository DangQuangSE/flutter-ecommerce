import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';

void main() {
  group('Success', () {
    test('holds typed data', () {
      const result = Success<String>('hello');
      expect(result.data, 'hello');
    });

    test('holds int data', () {
      const result = Success<int>(42);
      expect(result.data, 42);
    });
  });

  group('ResultFailure', () {
    test('holds a Failure', () {
      const failure = NetworkFailure('network error', statusCode: 503);
      const result = ResultFailure<String>(failure);
      expect(result.failure, failure);
      expect(result.failure.message, 'network error');
    });

    test('holds DomainFailure', () {
      const failure = DomainFailure('unexpected');
      const result = ResultFailure<int>(failure);
      expect(result.failure, isA<DomainFailure>());
    });
  });

  group('Result sealed pattern matching', () {
    test('switch on Success returns data', () {
      const Result<int> result = Success<int>(10);
      final value = switch (result) {
        Success(:final data) => data,
        ResultFailure() => -1,
      };
      expect(value, 10);
    });

    test('switch on ResultFailure returns failure', () {
      const Result<int> result = ResultFailure<int>(ParseFailure('bad json'));
      final message = switch (result) {
        Success() => 'ok',
        ResultFailure(:final failure) => failure.message,
      };
      expect(message, 'bad json');
    });
  });
}
