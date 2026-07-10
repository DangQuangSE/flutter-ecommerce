import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/data/services/device_location_service.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geocoded_place.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/route_preview.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/directions_repository.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_state.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────

class _FakeDirectionsRepository implements DirectionsRepository {
  Future<Result<RoutePreview>> Function({
    required GeoPoint origin,
    required GeoPoint destination,
  })? handler;
  bool called = false;

  @override
  Future<Result<RoutePreview>> getDrivingRoute({
    required GeoPoint origin,
    required GeoPoint destination,
  }) {
    called = true;
    return handler!(origin: origin, destination: destination);
  }
}

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

/// `DeviceLocationService` is a concrete (non-abstract) class, so we fake it
/// via subclassing rather than reimplementing an interface.
class _FakeDeviceLocationService extends DeviceLocationService {
  Result<GeoPoint> Function()? handler;
  bool openSettingsCalled = false;

  @override
  Future<Result<GeoPoint>> currentPosition() async => handler!();

  @override
  Future<void> openSettings() async {
    openSettingsCalled = true;
  }
}

// ── Fixtures ─────────────────────────────────────────────────────────────────

const _origin = GeoPoint(latitude: 10.0, longitude: 106.0);
const _destination = GeoPoint(latitude: 10.5, longitude: 106.5);
const _route = RoutePreview(
  polyline: [_origin, _destination],
  distanceText: '5 km',
  durationText: '10 phút',
  distanceMeters: 5000,
  durationSeconds: 600,
);

/// Collects all states emitted from [cubit] while [action] is running.
/// The initial state is NOT included — only transitions.
Future<List<DirectionsState>> _collectStates(
  DirectionsCubit cubit,
  Future<void> Function() action,
) async {
  final states = <DirectionsState>[];
  final sub = cubit.stream.listen(states.add);
  await action();
  await sub.cancel();
  return states;
}

void main() {
  late _FakeDirectionsRepository fakeDirectionsRepo;
  late _FakePlacesRepository fakePlacesRepo;
  late _FakeDeviceLocationService fakeLocationService;
  late DirectionsCubit cubit;

  setUp(() {
    fakeDirectionsRepo = _FakeDirectionsRepository();
    fakePlacesRepo = _FakePlacesRepository();
    fakeLocationService = _FakeDeviceLocationService();
    cubit = DirectionsCubit(
      fakeDirectionsRepo,
      fakePlacesRepo,
      fakeLocationService,
    );
  });

  tearDown(() => cubit.close());

  test('initial state is DirectionsInitial', () {
    expect(cubit.state, isA<DirectionsInitial>());
  });

  group('loadRoute', () {
    test('emits [Loading, Loaded] on the happy path', () async {
      fakeLocationService.handler = () => const Success(_origin);
      fakeDirectionsRepo.handler = (
              {required origin, required destination}) async =>
          const Success(_route);

      final states = await _collectStates(cubit, () async {
        await cubit.loadRoute(destination: _destination);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      expect(states.length, 2);
      expect(states[0], isA<DirectionsLoading>());
      expect(states[1], isA<DirectionsLoaded>());
      final loaded = states[1] as DirectionsLoaded;
      expect(loaded.route, _route);
      expect(loaded.origin, _origin);
    });

    test(
        'emits DirectionsError with permanentlyDenied propagated when '
        'location permission is permanently denied', () async {
      fakeLocationService.handler = () => const ResultFailure(
            LocationFailure(
              'Quyền vị trí đã bị từ chối.',
              permanentlyDenied: true,
            ),
          );

      final states = await _collectStates(cubit, () async {
        await cubit.loadRoute(destination: _destination);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      expect(states.length, 2);
      expect(states[0], isA<DirectionsLoading>());
      expect(states[1], isA<DirectionsError>());
      final error = states[1] as DirectionsError;
      expect(error.message, 'Quyền vị trí đã bị từ chối.');
      expect(error.permanentlyDenied, isTrue);
      // The route should never be requested once location resolution fails.
      expect(fakeDirectionsRepo.called, isFalse);
    });

    test('emits DirectionsError when the route call fails', () async {
      fakeLocationService.handler = () => const Success(_origin);
      fakeDirectionsRepo.handler = (
              {required origin, required destination}) async =>
          const ResultFailure(NetworkFailure('Không thể tải chỉ đường'));

      final states = await _collectStates(cubit, () async {
        await cubit.loadRoute(destination: _destination);
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });

      expect(states.length, 2);
      expect(states[0], isA<DirectionsLoading>());
      expect(states[1], isA<DirectionsError>());
      final error = states[1] as DirectionsError;
      expect(error.message, 'Không thể tải chỉ đường');
      expect(error.permanentlyDenied, isFalse);
    });
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

  group('reset', () {
    test('returns the cubit to DirectionsInitial', () async {
      fakeLocationService.handler = () => const Success(_origin);
      fakeDirectionsRepo.handler = (
              {required origin, required destination}) async =>
          const Success(_route);
      await cubit.loadRoute(destination: _destination);
      expect(cubit.state, isA<DirectionsLoaded>());

      cubit.reset();

      expect(cubit.state, isA<DirectionsInitial>());
    });
  });
}
