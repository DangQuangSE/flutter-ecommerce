import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:flutter_ecommerce/core/constants/app_strings.dart';
import 'package:flutter_ecommerce/core/errors/failures.dart';
import 'package:flutter_ecommerce/core/errors/result.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geo_point.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/geocoded_place.dart';
import 'package:flutter_ecommerce/features/geo/domain/entities/place_suggestion.dart';
import 'package:flutter_ecommerce/features/geo/domain/repositories/places_repository.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_cubit.dart';
import 'package:flutter_ecommerce/features/geo/presentation/cubit/directions_state.dart';
import 'package:flutter_ecommerce/features/geo/presentation/widgets/store_map_view.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_directions_fab.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_placeholder.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_section.dart';

// ── Fakes ────────────────────────────────────────────────────────────────────
//
// Same style as test/features/geo/directions_cubit_test.dart and
// test/features/geo/store_location_picker_cubit_test.dart: plain fakes
// implementing the abstract repository interfaces, no mockito/mocktail.

class _FakePlacesRepository implements PlacesRepository {
  Future<Result<GeocodedPlace>> Function(String address)? geocodeHandler;

  @override
  Future<Result<List<PlaceSuggestion>>> autocomplete(String query) async =>
      const Success([]);

  @override
  Future<Result<GeocodedPlace>> geocodeAddress(String address) =>
      geocodeHandler!(address);

  @override
  Future<Result<GeocodedPlace>> reverseGeocode(GeoPoint point) async =>
      const ResultFailure(NetworkFailure('unused in these tests'));
}

/// Fakes `url_launcher`'s platform channel by swapping out
/// `UrlLauncherPlatform.instance` (the package's own recommended seam for
/// testing — no mockito/platform-channel stubbing needed). There is no
/// existing url_launcher test pattern elsewhere in this repo, so this is a
/// new (but minimal, dependency-free) one.
class _FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  String? lastUrl;
  int callCount = 0;
  Future<bool> Function(String url)? launchHandler;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    callCount++;
    lastUrl = url;
    final handler = launchHandler;
    return handler == null ? true : await handler(url);
  }
}

// ── Fixtures ─────────────────────────────────────────────────────────────────

const _shopWithCoords = ShopEntity(
  name: 'Sport Pro',
  address: '123 Nguyễn Trãi, Quận 1',
  latitude: 10.7769,
  longitude: 106.7009,
  placeId: 'PLACE_ID_1',
);

const _shopNeedingGeocode = ShopEntity(
  name: 'Sport Pro 2',
  address: '456 Lê Lợi, Quận 1',
);

const _shopWithNoAddress = ShopEntity(name: 'Sport Pro 3');

const _geocodedPoint = GeoPoint(latitude: 10.8, longitude: 106.6);

void main() {
  late UrlLauncherPlatform originalUrlLauncherPlatform;
  late _FakeUrlLauncherPlatform fakeUrlLauncher;
  late _FakePlacesRepository fakePlaces;
  late DirectionsCubit cubit;

  setUpAll(() {
    // google_fonts otherwise tries to fetch font files over the network the
    // first time each style is used — irrelevant to this widget's behavior
    // and an unnecessary source of test flakiness/slowness.
    GoogleFonts.config.allowRuntimeFetching = false;
    originalUrlLauncherPlatform = UrlLauncherPlatform.instance;
  });

  tearDownAll(() {
    UrlLauncherPlatform.instance = originalUrlLauncherPlatform;
  });

  setUp(() {
    fakeUrlLauncher = _FakeUrlLauncherPlatform();
    UrlLauncherPlatform.instance = fakeUrlLauncher;
    fakePlaces = _FakePlacesRepository();
    cubit = DirectionsCubit(fakePlaces);
  });

  tearDown(() => cubit.close());

  Widget wrap(ShopEntity shop) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<DirectionsCubit>.value(
          value: cubit,
          child: ShopMapSection(shop: shop, height: 260),
        ),
      ),
    );
  }

  group('resolving the store point', () {
    testWidgets(
        'shows a loading indicator while the address is being geocoded, '
        'then the map once it resolves', (tester) async {
      final geocodeCompleter = Completer<Result<GeocodedPlace>>();
      fakePlaces.geocodeHandler = (_) => geocodeCompleter.future;

      await tester.pumpWidget(wrap(_shopNeedingGeocode));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(StoreMapView), findsNothing);
      expect(find.byType(ShopMapPlaceholder), findsNothing);

      geocodeCompleter.complete(
        const Success(
          GeocodedPlace(point: _geocodedPoint, formattedAddress: 'Đã tìm thấy'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(StoreMapView), findsOneWidget);
    });

    testWidgets(
        'renders the map and directions FAB immediately for a shop that '
        'already has saved coordinates (no geocode call)', (tester) async {
      fakePlaces.geocodeHandler = (_) async {
        fail('geocodeAddress must not be called when hasCoordinates is true');
      };

      await tester.pumpWidget(wrap(_shopWithCoords));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(StoreMapView), findsOneWidget);
      expect(find.byType(ShopMapDirectionsFab), findsOneWidget);

      final mapView = tester.widget<StoreMapView>(find.byType(StoreMapView));
      const expectedPoint = GeoPoint(latitude: 10.7769, longitude: 106.7009);
      expect(mapView.center, expectedPoint);
      expect(mapView.storeMarker, expectedPoint);
      // No in-app route preview any more: no user marker, no polyline.
      expect(mapView.userMarker, isNull);
      expect(mapView.routePolyline, isEmpty);
    });

    testWidgets(
        'renders the map and directions FAB after a successful geocode '
        'fallback', (tester) async {
      fakePlaces.geocodeHandler = (address) async {
        expect(address, _shopNeedingGeocode.address);
        return const Success(
          GeocodedPlace(point: _geocodedPoint, formattedAddress: 'Đã tìm thấy'),
        );
      };

      await tester.pumpWidget(wrap(_shopNeedingGeocode));
      await tester.pumpAndSettle();

      expect(find.byType(StoreMapView), findsOneWidget);
      expect(find.byType(ShopMapDirectionsFab), findsOneWidget);
      final mapView = tester.widget<StoreMapView>(find.byType(StoreMapView));
      expect(mapView.center, _geocodedPoint);
      expect(mapView.storeMarker, _geocodedPoint);
    });

    testWidgets('shows ShopMapPlaceholder when geocoding the address fails',
        (tester) async {
      fakePlaces.geocodeHandler = (_) async =>
          const ResultFailure(NetworkFailure('Không tìm thấy toạ độ'));

      await tester.pumpWidget(wrap(_shopNeedingGeocode));
      await tester.pumpAndSettle();

      expect(find.byType(ShopMapPlaceholder), findsOneWidget);
      expect(find.byType(StoreMapView), findsNothing);
      expect(find.byType(ShopMapDirectionsFab), findsNothing);
    });

    testWidgets(
        'shows ShopMapPlaceholder without calling geocode when the shop has '
        'neither coordinates nor an address', (tester) async {
      fakePlaces.geocodeHandler = (_) async {
        fail('geocodeAddress must not be called for a null/blank address');
      };

      await tester.pumpWidget(wrap(_shopWithNoAddress));
      await tester.pumpAndSettle();

      expect(find.byType(ShopMapPlaceholder), findsOneWidget);
      expect(find.byType(StoreMapView), findsNothing);
    });
  });

  group('tapping "Chỉ đường" hands off to Google Maps immediately', () {
    testWidgets(
        'builds the directions URI with the destination and place id but no '
        'origin, launches it externally, and never starts an in-app route '
        'preview', (tester) async {
      await tester.pumpWidget(wrap(_shopWithCoords));

      await tester.tap(find.byType(ShopMapDirectionsFab));
      await tester.pumpAndSettle();

      expect(fakeUrlLauncher.callCount, 1);
      final uri = Uri.parse(fakeUrlLauncher.lastUrl!);
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/dir/');
      expect(uri.queryParameters['destination'], '10.7769,106.7009');
      expect(uri.queryParameters['destination_place_id'], 'PLACE_ID_1');
      expect(uri.queryParameters['travelmode'], 'driving');
      // Key behavior change: Google Maps fills in the origin itself.
      expect(uri.queryParameters.containsKey('origin'), isFalse);

      // No in-app preview: the route/ETA cubit flow is never touched.
      expect(cubit.state, isA<DirectionsInitial>());
      expect(find.text(AppStrings.shopMapOpenError), findsNothing);
    });

    testWidgets('omits destination_place_id when the shop has none',
        (tester) async {
      fakePlaces.geocodeHandler = (_) async => const Success(
            GeocodedPlace(
              point: _geocodedPoint,
              formattedAddress: 'Đã tìm thấy',
            ),
          );

      await tester.pumpWidget(wrap(_shopNeedingGeocode));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ShopMapDirectionsFab));
      await tester.pumpAndSettle();

      final uri = Uri.parse(fakeUrlLauncher.lastUrl!);
      expect(uri.queryParameters['destination'], '10.8,106.6');
      expect(uri.queryParameters.containsKey('destination_place_id'), isFalse);
      expect(uri.queryParameters.containsKey('origin'), isFalse);
    });

    testWidgets(
        'guards against double taps while a launch is already in flight',
        (tester) async {
      final launchCompleter = Completer<bool>();
      fakeUrlLauncher.launchHandler = (_) => launchCompleter.future;

      await tester.pumpWidget(wrap(_shopWithCoords));

      await tester.tap(find.byType(ShopMapDirectionsFab));
      await tester.pump();
      // Second tap while the first launch is still pending must be a no-op,
      // both because the FAB disables itself (loading: true) and because of
      // the internal `_launchingDirections` guard.
      await tester.tap(find.byType(ShopMapDirectionsFab));
      await tester.pump();

      expect(fakeUrlLauncher.callCount, 1);
      expect(find.text(AppStrings.shopDirectionsLoading), findsOneWidget);

      launchCompleter.complete(true);
      await tester.pumpAndSettle();

      expect(fakeUrlLauncher.callCount, 1);
      expect(find.text(AppStrings.shopGetDirections), findsOneWidget);
    });

    testWidgets(
        'shows a SnackBar with shopMapOpenError when Google Maps cannot be '
        'launched', (tester) async {
      fakeUrlLauncher.launchHandler = (_) async => false;

      await tester.pumpWidget(wrap(_shopWithCoords));
      await tester.tap(find.byType(ShopMapDirectionsFab));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.shopMapOpenError), findsOneWidget);
    });

    testWidgets(
        'recovers (resets loading, shows the error) instead of getting stuck '
        'if launchUrl throws', (tester) async {
      fakeUrlLauncher.launchHandler = (_) => throw Exception('no activity');

      await tester.pumpWidget(wrap(_shopWithCoords));
      await tester.tap(find.byType(ShopMapDirectionsFab));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.shopMapOpenError), findsOneWidget);
      // The FAB must re-enable, not stay stuck on the loading label.
      expect(find.text(AppStrings.shopGetDirections), findsOneWidget);
      expect(find.text(AppStrings.shopDirectionsLoading), findsNothing);

      // A second tap after recovery must be able to launch normally.
      fakeUrlLauncher.launchHandler = (_) async => true;
      await tester.tap(find.byType(ShopMapDirectionsFab));
      await tester.pumpAndSettle();

      expect(fakeUrlLauncher.callCount, 2);
    });
  });
}
