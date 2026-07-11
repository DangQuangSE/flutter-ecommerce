import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_ecommerce/core/constants/app_sizes.dart';
import 'package:flutter_ecommerce/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_cover_header.dart';
import 'package:flutter_ecommerce/features/shop/presentation/widgets/shop_map_directions_fab.dart';

const _shop = ShopEntity(
  name: 'Sport Pro',
  address: '181, Le Thanh Ton Street',
  latitude: 10.7769,
  longitude: 106.7009,
);

Future<void> _pumpAt(WidgetTester tester, Size size) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  await tester.pumpWidget(
    const MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [ShopCoverHeader(shop: _shop)],
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
      'the directions FAB stays within a bounded distance from the top on a '
      'phone-sized viewport', (tester) async {
    addTearDown(tester.view.reset);
    await _pumpAt(tester, const Size(390, 844));

    final fabTop =
        tester.getTopLeft(find.byType(ShopMapDirectionsFab)).dy;

    expect(fabTop, lessThan(AppSizes.shopCoverMaxHeight));
  });

  testWidgets(
      'caps the map/header height on a wide (tablet/web) viewport so the '
      'directions FAB never gets pushed below the fold', (tester) async {
    addTearDown(tester.view.reset);
    // A width whose uncapped ratio (2400 * 0.42 = 1008) would land the FAB
    // far outside a typical viewport if the height weren't capped.
    await _pumpAt(tester, const Size(2400, 900));

    final fabTop =
        tester.getTopLeft(find.byType(ShopMapDirectionsFab)).dy;

    expect(fabTop, lessThan(AppSizes.shopCoverMaxHeight));
  });
}
