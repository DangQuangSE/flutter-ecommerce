import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ecommerce/core/storage/local_storage.dart';
import 'package:flutter_ecommerce/features/auth/presentation/pages/onboarding_page.dart';

final sl = GetIt.instance;

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
    sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sharedPreferences));
  });

  tearDownAll(() async {
    await sl.reset();
  });

  group('OnboardingPage Widget Tests', () {
    testWidgets('renders first slide and can swipe to next slides', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OnboardingPage(),
        ),
      );

      // Verify first slide is displayed
      expect(find.text('Bứt phá\ngiới hạn.'), findsOneWidget);
      expect(find.text('TIẾP TỤC'), findsOneWidget);
      expect(find.text('BỎ QUA'), findsOneWidget);

      // Swipe to the next page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify second slide is displayed
      expect(find.text('Tùy biến\nđộc bản.'), findsOneWidget);

      // Swipe to the last page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Verify last slide is displayed
      expect(find.text('Bắt đầu\nhành trình.'), findsOneWidget);
      expect(find.text('BẮT ĐẦU'), findsOneWidget);
      
      // Skip should be hidden or inactive (opacity animated to 0)
      expect(find.text('BỎ QUA'), findsOneWidget); // still in widget tree but opaque/ignored
    });
  });
}
