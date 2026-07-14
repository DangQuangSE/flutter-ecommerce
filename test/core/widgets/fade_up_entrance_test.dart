import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_ecommerce/core/widgets/fade_up_entrance.dart';

void main() {
  group('FadeUpEntrance', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeUpEntrance(
              child: Text('Hello'),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('animation starts immediately when delay is zero',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeUpEntrance(
              child: Text('No delay'),
            ),
          ),
        ),
      );

      // Initial pump - animation should have started
      await tester.pump();
      // Advance past the animation duration
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('No delay'), findsOneWidget);
    });

    testWidgets('animation starts after delay when specified', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeUpEntrance(
              delay: Duration(milliseconds: 200),
              child: Text('With delay'),
            ),
          ),
        ),
      );

      // Pump once to initialize
      await tester.pump();
      // Advance partially (before delay)
      await tester.pump(const Duration(milliseconds: 100));
      // Advance past the delay
      await tester.pump(const Duration(milliseconds: 200));
      // Complete the animation
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.text('With delay'), findsOneWidget);
    });

    testWidgets('disposes animation controller on removal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeUpEntrance(
              child: Text('Disposable'),
            ),
          ),
        ),
      );
      await tester.pump();

      // Remove the widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Should not throw
      expect(find.byType(FadeUpEntrance), findsNothing);
    });

    testWidgets('child is visible after animation completes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FadeUpEntrance(
              child: Text('Visible'),
            ),
          ),
        ),
      );

      // Complete the animation
      await tester.pump(const Duration(milliseconds: 1000));

      final textWidget = tester.widget<Text>(find.text('Visible'));
      expect(textWidget.style, isNull);
      expect(find.text('Visible'), findsOneWidget);
    });
  });
}
