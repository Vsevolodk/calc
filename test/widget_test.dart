import 'package:calc/calculator.dart';
import 'package:calc/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Calculator', () {
    late Calculator c;
    setUp(() => c = Calculator());

    void digits(String s) {
      for (final ch in s.split('')) {
        ch == '.' ? c.inputDecimal() : c.inputDigit(ch);
      }
    }

    test('сложение', () {
      digits('12');
      c.setOperator('+');
      digits('30');
      c.equals();
      expect(c.display, '42');
    });

    test('цепочка операций слева направо', () {
      digits('2');
      c.setOperator('+');
      digits('3');
      c.setOperator('×');
      expect(c.display, '5');
      digits('4');
      c.equals();
      expect(c.display, '20');
    });

    test('дробные числа без погрешности в отображении', () {
      digits('0.1');
      c.setOperator('+');
      digits('0.2');
      c.equals();
      expect(c.display, '0.3');
    });

    test('деление на ноль даёт ошибку', () {
      digits('5');
      c.setOperator('÷');
      digits('0');
      c.equals();
      expect(c.display, 'Ошибка');
      digits('7');
      expect(c.display, '7');
    });

    test('процент, смена знака, удаление', () {
      digits('50');
      c.percent();
      expect(c.display, '0.5');
      c.toggleSign();
      expect(c.display, '-0.5');
      c.backspace();
      expect(c.display, '-0.');
    });

    test('одна десятичная точка', () {
      digits('1..5.');
      expect(c.display, '1.5');
    });
  });

  testWidgets('нажатие кнопок обновляет экран', (tester) async {
    await tester.pumpWidget(const CalcApp());

    for (final label in ['7', '×', '6', '=']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }

    expect(
      tester.widget<Text>(find.byKey(const Key('display'))).data,
      '42',
    );
  });
}
