import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calculator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const CalcApp());
}

class CalcApp extends StatelessWidget {
  const CalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Калькулятор',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.dark,
        ),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

enum _Kind { digit, function, operator }

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _calc = Calculator();

  void _update(VoidCallback action) => setState(action);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(flex: 2, child: _buildDisplay(scheme)),
              _buildRow([
                _button(_calc.hasInput ? 'C' : 'AC', _Kind.function,
                    () => _calc.hasInput ? _calc.clearEntry() : _calc.clearAll()),
                _button('±', _Kind.function, _calc.toggleSign),
                _button('%', _Kind.function, _calc.percent),
                _operatorButton('÷'),
              ]),
              _buildRow([
                _digitButton('7'),
                _digitButton('8'),
                _digitButton('9'),
                _operatorButton('×'),
              ]),
              _buildRow([
                _digitButton('4'),
                _digitButton('5'),
                _digitButton('6'),
                _operatorButton('−'),
              ]),
              _buildRow([
                _digitButton('1'),
                _digitButton('2'),
                _digitButton('3'),
                _operatorButton('+'),
              ]),
              _buildRow([
                _button('⌫', _Kind.function, _calc.backspace),
                _digitButton('0'),
                _button(',', _Kind.digit, _calc.inputDecimal),
                _button('=', _Kind.operator, _calc.equals),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisplay(ColorScheme scheme) {
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomRight,
        child: Text(
          _calc.display.replaceAll('.', ','),
          key: const Key('display'),
          maxLines: 1,
          style: TextStyle(
            fontSize: 80,
            fontWeight: FontWeight.w300,
            color: scheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<Widget> buttons) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons.map((b) => Expanded(child: b)).toList(),
      ),
    );
  }

  Widget _digitButton(String digit) =>
      _button(digit, _Kind.digit, () => _calc.inputDigit(digit));

  Widget _operatorButton(String op) => _button(
        op,
        _Kind.operator,
        () => _calc.setOperator(op),
        selected: _calc.pendingOperator == op,
      );

  Widget _button(
    String label,
    _Kind kind,
    VoidCallback onPressed, {
    bool selected = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final (Color bg, Color fg) = switch (kind) {
      _Kind.digit => (scheme.surfaceContainerHighest, scheme.onSurface),
      _Kind.function => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      _Kind.operator => selected
          ? (scheme.onPrimary, scheme.primary)
          : (scheme.primary, scheme.onPrimary),
    };

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            _update(onPressed);
          },
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
