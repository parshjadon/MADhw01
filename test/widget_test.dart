import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calculator_app/main.dart';

String displayValue(WidgetTester tester) {
  return tester.widget<Text>(find.byKey(const Key('display_text'))).data!;
}

Future<void> tapButton(WidgetTester tester, String label) async {
  final matches = find.byWidgetPredicate(
    (widget) => widget.key.toString().contains('calc_button_${label}_'),
  );
  expect(matches, findsWidgets, reason: 'Expected calculator button $label');
  await tester.tap(matches.first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('adds two operands and shows the result', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, '7');
    await tapButton(tester, '+');
    await tapButton(tester, '5');
    await tapButton(tester, '=');

    expect(displayValue(tester), '12');
  });

  testWidgets('supports decimal input and prevents duplicate decimals', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, '1');
    await tapButton(tester, '.');
    await tapButton(tester, '.');
    await tapButton(tester, '5');
    await tapButton(tester, '+');
    await tapButton(tester, '2');
    await tapButton(tester, '.');
    await tapButton(tester, '2');
    await tapButton(tester, '5');
    await tapButton(tester, '=');

    expect(displayValue(tester), '3.75');
  });

  testWidgets('division keeps fractional results when needed', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, '7');
    await tapButton(tester, '/');
    await tapButton(tester, '2');
    await tapButton(tester, '=');

    expect(displayValue(tester), '3.5');
  });

  testWidgets('advanced operations support sign, square root, and percent', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, '9');
    await tapButton(tester, 'sqrt');
    expect(displayValue(tester), '3');

    await tapButton(tester, '+/-');
    expect(displayValue(tester), '-3');

    await tapButton(tester, 'AC');
    await tapButton(tester, '5');
    await tapButton(tester, '0');
    await tapButton(tester, '%');
    expect(displayValue(tester), '0.5');
  });

  testWidgets('delete handles decimal input and long press clears state', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, '1');
    await tapButton(tester, '2');
    await tapButton(tester, '.');
    await tapButton(tester, '3');
    await tapButton(tester, 'DEL');
    expect(displayValue(tester), '12.');

    await tester.longPress(
      find
          .byWidgetPredicate(
            (widget) => widget.key.toString().contains('calc_button_DEL_'),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(displayValue(tester), '0');
  });

  testWidgets(
    'history records results, can reuse a result, and can be cleared',
    (tester) async {
      await tester.pumpWidget(const CalculatorApp());

      await tapButton(tester, '8');
      await tapButton(tester, 'x');
      await tapButton(tester, '7');
      await tapButton(tester, '=');

      expect(find.text('8 x 7'), findsOneWidget);
      expect(find.text('56'), findsWidgets);

      await tester.tap(find.text('8 x 7'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(displayValue(tester), '56');

      await tester.tap(find.byKey(const Key('clear_history_button')));
      await tester.pumpAndSettle();
      expect(find.text('No history yet'), findsOneWidget);
    },
  );

  testWidgets('division by zero is recoverable', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    await tapButton(tester, '8');
    await tapButton(tester, '/');
    await tapButton(tester, '0');
    await tapButton(tester, '=');

    expect(displayValue(tester), 'Error');
    expect(
      find.text('Cannot divide by zero. Tap AC to start again.'),
      findsOneWidget,
    );

    await tapButton(tester, 'AC');
    expect(displayValue(tester), '0');
  });

  testWidgets('theme toggle switches to dark mode', (tester) async {
    await tester.pumpWidget(const CalculatorApp());

    final materialAppBefore = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(materialAppBefore.themeMode, ThemeMode.light);

    await tester.tap(find.byKey(const Key('theme_toggle')));
    await tester.pumpAndSettle();

    final materialAppAfter = tester.widget<MaterialApp>(
      find.byType(MaterialApp),
    );
    expect(materialAppAfter.themeMode, ThemeMode.dark);
  });
}
