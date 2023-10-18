// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:counter_test/main.dart';

void main() {
  group("Counter Clas", () {
    test('Counter value should start at 0', () {
      expect(Counter().value, 0);
    });

    test('Counter value should be incremented', () {
      final counter = Counter();
      counter.increment();
      expect(counter.value, 1);
    });

    test('Counter value should be decremented', () {
      final counter = Counter();
      counter.decrement();
      expect(counter.value, -1);
    });

    test('Counter value add arbritrary', () {
      final counter = Counter();
      expect(counter.value, 0);
      counter.addValue(2);
      expect(counter.value, 2);
    });

    test('Counter value subtract arbritrary', () {
      final counter = Counter();
      expect(counter.value, 0);
      counter.addValue(-2);
      expect(counter.value, -2);
    });
  });

  testWidgets('Counter decrements smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('-1'), findsOneWidget);
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
