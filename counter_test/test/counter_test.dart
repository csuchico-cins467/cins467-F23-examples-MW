import 'package:counter_test/main.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
