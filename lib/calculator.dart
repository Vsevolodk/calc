/// Логика простого калькулятора с немедленным выполнением операций
/// (как в стандартном калькуляторе телефона).
class Calculator {
  static const int _maxDigits = 12;

  String _display = '0';
  double? _accumulator;
  String? _operator;
  bool _startNewInput = true;
  bool _error = false;

  /// Текст, отображаемый на экране.
  String get display => _display;

  /// Текущая выбранная операция (для подсветки кнопки).
  String? get pendingOperator => _startNewInput ? _operator : null;

  /// true, если на экране введено число (кнопка очистки показывает «C»).
  bool get hasInput => !_startNewInput && _display != '0';

  void inputDigit(String digit) {
    if (_error) clearAll();
    if (_startNewInput) {
      _display = digit;
      _startNewInput = false;
      return;
    }
    if (_digitCount(_display) >= _maxDigits) return;
    _display = _display == '0' ? digit : _display + digit;
  }

  void inputDecimal() {
    if (_error) clearAll();
    if (_startNewInput) {
      _display = '0.';
      _startNewInput = false;
      return;
    }
    if (!_display.contains('.')) _display += '.';
  }

  void setOperator(String op) {
    if (_error) return;
    if (_operator != null && !_startNewInput) {
      _evaluate();
      if (_error) return;
    } else {
      _accumulator = double.parse(_display);
    }
    _operator = op;
    _startNewInput = true;
  }

  void equals() {
    if (_error || _operator == null) return;
    _evaluate();
    _operator = null;
    _startNewInput = true;
  }

  void toggleSign() {
    if (_error || _display == '0') return;
    _display = _display.startsWith('-') ? _display.substring(1) : '-$_display';
    if (_startNewInput) {
      // Знак меняется у результата: его можно использовать дальше.
      _accumulator = double.parse(_display);
    }
  }

  void percent() {
    if (_error) return;
    _display = _format(double.parse(_display) / 100);
    _startNewInput = false;
  }

  void backspace() {
    if (_error || _startNewInput) return;
    _display = _display.length > 1 ? _display.substring(0, _display.length - 1) : '0';
    if (_display == '-') _display = '0';
  }

  /// «C»: очищает только текущий ввод.
  void clearEntry() {
    _display = '0';
    _startNewInput = _operator == null;
  }

  /// «AC»: полный сброс.
  void clearAll() {
    _display = '0';
    _accumulator = null;
    _operator = null;
    _startNewInput = true;
    _error = false;
  }

  void _evaluate() {
    final a = _accumulator ?? 0;
    final b = double.parse(_display);
    double result;
    switch (_operator) {
      case '+':
        result = a + b;
      case '−':
        result = a - b;
      case '×':
        result = a * b;
      case '÷':
        if (b == 0) {
          _setError();
          return;
        }
        result = a / b;
      default:
        result = b;
    }
    if (result.isNaN || result.isInfinite) {
      _setError();
      return;
    }
    _accumulator = result;
    _display = _format(result);
  }

  void _setError() {
    _display = 'Ошибка';
    _accumulator = null;
    _operator = null;
    _startNewInput = true;
    _error = true;
  }

  static int _digitCount(String s) => s.replaceAll(RegExp(r'[^0-9]'), '').length;

  static String _format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e12) {
      return value.toInt().toString();
    }
    var s = value.toStringAsPrecision(_maxDigits);
    if (s.contains('e')) {
      final parts = s.split('e');
      var mantissa = parts[0];
      if (mantissa.contains('.')) {
        mantissa = mantissa.replaceFirst(RegExp(r'\.?0+$'), '');
      }
      return '${mantissa}e${parts[1]}';
    }
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    }
    return s;
  }
}
