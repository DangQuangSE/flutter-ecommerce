import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geocoded_place.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_state.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakePlacesRepository implements PlacesRepository {
  Future<Result<List<PlaceSuggestion>>> Function(String query)?
      autocompleteHandler;
  Future<Result<GeocodedPlace>> Function(String address)? geocodeHandler;
  Future<Result<GeocodedPlace>> Function(GeoPoint point)? reverseGeocodeHandler;

  @override
  Future<Result<List<PlaceSuggestion>>> autocomplete(String query) =>
      autocompleteHandler!(query);

  @override
  Future<Result<GeocodedPlace>> geocodeAddress(String address) =>
      geocodeHandler!(address);

  @override
  Future<Result<GeocodedPlace>> reverseGeocode(GeoPoint point) =>
      reverseGeocodeHandler!(point);
}

// ── Fixtures ─────────────────────────────────────────────────────────────────

const _destination = GeoPoint(latitude: 10.5, longitude: 106.5);

void main() {
  late _FakePlacesRepository fakePlacesRepo;
  late DirectionsCubit cubit;

  setUp(() {
    fakePlacesRepo = _FakePlacesRepository();
    cubit = DirectionsCubit(fakePlacesRepo);
  });

  tearDown(() => cubit.close());

  test('initial state is DirectionsInitial', () {
    expect(cubit.state, isA<DirectionsInitial>());
  });

  group('geocodeStoreAddress', () {
    test('returns the resolved GeoPoint on success', () async {
      fakePlacesRepo.geocodeHandler = (address) async => const Success(
            GeocodedPlace(point: _destination, formattedAddress: 'Địa chỉ'),
          );

      final point = await cubit.geocodeStoreAddress('123 Test St');

      expect(point, _destination);
    });

    test('returns null on geocoding failure', () async {
      fakePlacesRepo.geocodeHandler = (address) async =>
          const ResultFailure(NetworkFailure('Không tìm thấy toạ độ'));

      final point = await cubit.geocodeStoreAddress('123 Test St');

      expect(point, isNull);
    });

    test('returns null for a blank address without calling the repository',
        () async {
      var repositoryCalled = false;
      fakePlacesRepo.geocodeHandler = (address) async {
        repositoryCalled = true;
        return const ResultFailure(NetworkFailure('unused'));
      };

      final point = await cubit.geocodeStoreAddress('   ');

      expect(point, isNull);
      expect(repositoryCalled, isFalse);
    });
  });
}
