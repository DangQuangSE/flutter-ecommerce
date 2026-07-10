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
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_directions_row.dart';

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

class _FakeUrlLauncherPlatform extends UrlLauncherPlatform {
  int callCount = 0;
  Future<bool> Function(String url)? launchHandler;

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    callCount++;
    final handler = launchHandler;
    return handler == null ? true : await handler(url);
  }
}

const _shopWithCoords = ShopEntity(
  name: 'Sport Pro',
  latitude: 10.7769,
  longitude: 106.7009,
);

const _shopNeedingGeocode = ShopEntity(
  name: 'Sport Pro',
  address: '181, Le Thanh Ton Street',
);

const _shopWithNoLocation = ShopEntity(name: 'Sport Pro');

void main() {
  late UrlLauncherPlatform originalUrlLauncherPlatform;
  late _FakeUrlLauncherPlatform fakeUrlLauncher;
  late _FakePlacesRepository fakePlaces;
  late DirectionsCubit cubit;

  setUpAll(() {
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
          child: ShopDirectionsRow(shop: shop),
        ),
      ),
    );
  }

  testWidgets('tapping the row with saved coordinates launches Maps directly '
      '(no geocode call)', (tester) async {
    fakePlaces.geocodeHandler = (_) async {
      fail('geocodeAddress must not be called when hasCoordinates is true');
    };

    await tester.pumpWidget(wrap(_shopWithCoords));
    await tester.tap(find.text(AppStrings.shopGetDirections));
    await tester.pumpAndSettle();

    expect(fakeUrlLauncher.callCount, 1);
  });

  testWidgets('tapping the row for a shop needing geocoding resolves the '
      'address first, then launches', (tester) async {
    fakePlaces.geocodeHandler = (address) async {
      expect(address, _shopNeedingGeocode.address);
      return const Success(
        GeocodedPlace(
          point: GeoPoint(latitude: 10.8, longitude: 106.6),
          formattedAddress: 'Đã tìm thấy',
        ),
      );
    };

    await tester.pumpWidget(wrap(_shopNeedingGeocode));
    await tester.tap(find.text(AppStrings.shopGetDirections));
    await tester.pumpAndSettle();

    expect(fakeUrlLauncher.callCount, 1);
  });

  testWidgets(
      'shows shopMapUnavailable and never launches when the shop has no '
      'coordinates or address', (tester) async {
    await tester.pumpWidget(wrap(_shopWithNoLocation));
    await tester.tap(find.text(AppStrings.shopGetDirections));
    await tester.pumpAndSettle();

    expect(fakeUrlLauncher.callCount, 0);
    expect(find.text(AppStrings.shopMapUnavailable), findsOneWidget);
  });

  testWidgets('shows shopMapOpenError when launchUrl returns false',
      (tester) async {
    fakeUrlLauncher.launchHandler = (_) async => false;

    await tester.pumpWidget(wrap(_shopWithCoords));
    await tester.tap(find.text(AppStrings.shopGetDirections));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.shopMapOpenError), findsOneWidget);
  });

  testWidgets('guards against double taps while a launch is in flight',
      (tester) async {
    final launchCompleter = Completer<bool>();
    fakeUrlLauncher.launchHandler = (_) => launchCompleter.future;

    await tester.pumpWidget(wrap(_shopWithCoords));
    await tester.tap(find.text(AppStrings.shopGetDirections));
    await tester.pump();
    await tester.tap(find.text(AppStrings.shopGetDirections));
    await tester.pump();

    expect(fakeUrlLauncher.callCount, 1);

    launchCompleter.complete(true);
    await tester.pumpAndSettle();

    expect(fakeUrlLauncher.callCount, 1);
  });
}
