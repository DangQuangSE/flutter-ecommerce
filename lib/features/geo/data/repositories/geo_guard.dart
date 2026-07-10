import 'package:flutter_ecommerce/core/errors/exceptions.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';

/// Shared exception→[Failure] mapping for the geo data layer, mirroring the
/// `_guard` used by other repositories (e.g. `ShopRepositoryImpl`).
Future<Result<T>> geoGuard<T>(Future<T> Function() action) async {
  try {
    return Success(await action());
  } on UnauthorisedException catch (e) {
    return ResultFailure(AuthFailure(e.message));
  } on ServerException catch (e) {
    return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
  } on NetworkException catch (e) {
    return ResultFailure(NetworkFailure(e.message, statusCode: e.statusCode));
  } on ParseException catch (e) {
    return ResultFailure(ParseFailure(e.message));
  } on AppException catch (e) {
    return ResultFailure(NetworkFailure(e.message));
  } catch (_) {
    // Catch-all (e.g. an unexpected TypeError from a malformed Google response)
    // so the caller always gets a Result and never hangs in a Loading state.
    return const ResultFailure(ParseFailure('Dữ liệu bản đồ không hợp lệ'));
  }
}
