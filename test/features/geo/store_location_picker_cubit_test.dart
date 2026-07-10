import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geocoded_place.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/store_location_picker_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/store_location_picker_state.dart';

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

const _seedPoint = GeoPoint(latitude: 10.0, longitude: 106.0);
const _suggestionPoint = GeoPoint(latitude: 10.7769, longitude: 106.7009);
const _suggestion = PlaceSuggestion(
  description: 'Chợ Bến Thành, Quận 1',
  point: _suggestionPoint,
);

void main() {
  late _FakePlacesRepository fakeRepo;
  late StoreLocationPickerCubit cubit;

  setUp(() {
    fakeRepo = _FakePlacesRepository();
    cubit = StoreLocationPickerCubit(fakeRepo);
  });

  tearDown(() => cubit.close());

  test('initial state is StoreLocationPickerInitial', () {
    expect(cubit.state, isA<StoreLocationPickerInitial>());
  });

  test('initialize seeds the point and address', () {
    cubit.initialize(point: _seedPoint, address: '123 Test');

    final state = cubit.state as StoreLocationPickerReady;
    expect(state.point, _seedPoint);
    expect(state.address, '123 Test');
    expect(state.canSave, isTrue);
  });

  test('initialize with no point cannot save', () {
    cubit.initialize(address: 'unknown');
    expect((cubit.state as StoreLocationPickerReady).canSave, isFalse);
  });

  test('search populates suggestions and clears the searching flag', () async {
    fakeRepo.autocompleteHandler =
        (query) async => const Success([_suggestion]);

    await cubit.search('cho ben thanh');

    final state = cubit.state as StoreLocationPickerReady;
    expect(state.suggestions, [_suggestion]);
    expect(state.isSearching, isFalse);
  });

  test('search with a blank query clears suggestions without a call', () async {
    var called = false;
    fakeRepo.autocompleteHandler = (query) async {
      called = true;
      return const Success([_suggestion]);
    };

    await cubit.search('   ');

    expect((cubit.state as StoreLocationPickerReady).suggestions, isEmpty);
    expect(called, isFalse);
  });

  test('search failure emits StoreLocationPickerError', () async {
    fakeRepo.autocompleteHandler =
        (query) async => const ResultFailure(NetworkFailure('Lỗi mạng'));

    await cubit.search('x');

    expect(cubit.state, isA<StoreLocationPickerError>());
  });

  test('selectSuggestion drops the pin at the inline coordinate and clears list',
      () async {
    fakeRepo.autocompleteHandler =
        (query) async => const Success([_suggestion]);
    await cubit.search('cho ben thanh');

    cubit.selectSuggestion(_suggestion);

    final state = cubit.state as StoreLocationPickerReady;
    expect(state.point, _suggestionPoint);
    expect(state.address, 'Chợ Bến Thành, Quận 1');
    expect(state.suggestions, isEmpty);
    expect(state.canSave, isTrue);
  });

  test(
      'setPoint updates the coordinate and resolves the address (map tap to fine-tune)',
      () async {
    cubit.initialize(point: _seedPoint, address: 'seed');
    const dragged = GeoPoint(latitude: 10.5, longitude: 106.5);
    fakeRepo.reverseGeocodeHandler = (point) async => Success(
          GeocodedPlace(point: point, formattedAddress: 'Địa chỉ đã kéo pin'),
        );

    await cubit.setPoint(dragged);

    final state = cubit.state as StoreLocationPickerReady;
    expect(state.point, dragged);
    expect(state.address, 'Địa chỉ đã kéo pin');
    expect(state.isResolvingAddress, isFalse);
  });

  test('setPoint keeps the previous address when reverse geocoding fails',
      () async {
    cubit.initialize(point: _seedPoint, address: 'seed');
    const dragged = GeoPoint(latitude: 10.5, longitude: 106.5);
    fakeRepo.reverseGeocodeHandler =
        (point) async => const ResultFailure(NetworkFailure('Lỗi mạng'));

    await cubit.setPoint(dragged);

    final state = cubit.state as StoreLocationPickerReady;
    expect(state.point, dragged);
    expect(state.address, 'seed');
    expect(state.isResolvingAddress, isFalse);
  });
}
