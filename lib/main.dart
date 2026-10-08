import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff246bfe),
      brightness: Brightness.light,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff5dc8a8),
      brightness: Brightness.dark,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator Studio',
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _buildTheme(lightScheme),
      darkTheme: _buildTheme(darkScheme),
      home: CalculatorScreen(
        isDarkMode: _isDarkMode,
        onThemeChanged: _toggleTheme,
      ),
    );
  }

  ThemeData _buildTheme(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  double? _firstOperand;
  String? _pendingOperator;
  bool _replaceDisplayOnDigit = true;
  String? _errorMessage;
  final List<_HistoryItem> _history = [];

  bool get _hasError => _errorMessage != null;

  void _enterDigit(String digit) {
    setState(() {
      if (_hasError || _replaceDisplayOnDigit || _display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
      _replaceDisplayOnDigit = false;
      _errorMessage = null;
    });
  }

  void _enterDecimal() {
    setState(() {
      if (_hasError || _replaceDisplayOnDigit) {
        _display = '0.';
      } else if (!_display.contains('.')) {
        _display += '.';
      }
      _replaceDisplayOnDigit = false;
      _errorMessage = null;
    });
  }

  void _chooseOperator(String operator) {
    setState(() {
      if (_hasError) {
        _reset();
        return;
      }

      final currentValue = _parseDisplay();
      if (currentValue == null) {
        _showError('Enter a valid number before choosing an operator.');
        return;
      }

      if (_firstOperand != null &&
          _pendingOperator != null &&
          !_replaceDisplayOnDigit) {
        final result = _applyOperation(
          _firstOperand!,
          currentValue,
          _pendingOperator!,
        );
        if (result == null) {
          _showError('Cannot divide by zero. Tap AC to start again.');
          return;
        }
        _display = _formatResult(result);
        _firstOperand = result;
      } else {
        _firstOperand = currentValue;
      }

      _pendingOperator = operator;
      _replaceDisplayOnDigit = true;
      _errorMessage = null;
    });
  }

  void _calculate() {
    setState(() {
      if (_hasError) {
        _reset();
        return;
      }

      if (_firstOperand == null || _pendingOperator == null) {
        _showError(
          'Enter a number, choose an operator, then enter another number.',
        );
        return;
      }

      final secondOperand = _parseDisplay();
      if (secondOperand == null) {
        _showError('Enter a valid second number.');
        return;
      }

      final result = _applyOperation(
        _firstOperand!,
        secondOperand,
        _pendingOperator!,
      );
      if (result == null) {
        _showError('Cannot divide by zero. Tap AC to start again.');
        return;
      }

      final expression =
          '${_formatResult(_firstOperand!)} $_pendingOperator ${_formatResult(secondOperand)}';
      _display = _formatResult(result);
      _history.insert(
        0,
        _HistoryItem(expression: expression, result: _display),
      );
      _firstOperand = null;
      _pendingOperator = null;
      _replaceDisplayOnDigit = true;
      _errorMessage = null;
    });
  }

  double? _applyOperation(double left, double right, String operator) {
    switch (operator) {
      case '+':
        return left + right;
      case '-':
        return left - right;
      case 'x':
        return left * right;
      case '/':
        if (right == 0) {
          return null;
        }
        return left / right;
      default:
        throw ArgumentError('Unsupported operator $operator');
    }
  }

  void _applySquareRoot() {
    setState(() {
      final value = _parseDisplay();
      if (value == null) {
        _showError('Enter a valid number before using square root.');
        return;
      }
      if (value < 0) {
        _showError('Square root is not defined for negative values.');
        return;
      }
      final result = math.sqrt(value);
      final expression = 'sqrt(${_formatResult(value)})';
      _display = _formatResult(result);
      _history.insert(
        0,
        _HistoryItem(expression: expression, result: _display),
      );
      _replaceDisplayOnDigit = true;
      _errorMessage = null;
    });
  }

  void _applyPercent() {
    setState(() {
      final value = _parseDisplay();
      if (value == null) {
        _showError('Enter a valid number before using percent.');
        return;
      }

      final percentValue = _firstOperand == null
          ? value / 100
          : _firstOperand! * value / 100;
      _display = _formatResult(percentValue);
      _replaceDisplayOnDigit = false;
      _errorMessage = null;
    });
  }

  void _toggleSign() {
    setState(() {
      if (_hasError) {
        _reset();
        return;
      }
      if (_display == '0' || _display == '0.') {
        return;
      }
      _display = _display.startsWith('-')
          ? _display.substring(1)
          : '-$_display';
      _replaceDisplayOnDigit = false;
    });
  }

  void _deleteLast() {
    setState(() {
      if (_hasError) {
        _reset();
        return;
      }
      if (_replaceDisplayOnDigit && _pendingOperator != null) {
        _pendingOperator = null;
        _replaceDisplayOnDigit = false;
        return;
      }
      if (_display.length <= 1 ||
          (_display.length == 2 && _display.startsWith('-'))) {
        _display = '0';
        _replaceDisplayOnDigit = true;
      } else {
        _display = _display.substring(0, _display.length - 1);
        if (_display == '-0') {
          _display = '0';
        }
      }
      _errorMessage = null;
    });
  }

  void _clearEntry() {
    setState(() {
      _display = '0';
      _replaceDisplayOnDigit = true;
      _errorMessage = null;
    });
  }

  void _allClear() {
    setState(_reset);
  }

  void _clearHistory() {
    setState(_history.clear);
  }

  void _useHistoryResult(_HistoryItem item) {
    setState(() {
      _display = item.result;
      _firstOperand = null;
      _pendingOperator = null;
      _replaceDisplayOnDigit = true;
      _errorMessage = null;
    });
  }

  void _reset() {
    _display = '0';
    _firstOperand = null;
    _pendingOperator = null;
    _replaceDisplayOnDigit = true;
    _errorMessage = null;
  }

  void _showError(String message) {
    _display = 'Error';
    _firstOperand = null;
    _pendingOperator = null;
    _replaceDisplayOnDigit = true;
    _errorMessage = message;
  }

  double? _parseDisplay() {
    if (_display == '-' || _display == 'Error') {
      return null;
    }
    return double.tryParse(_display);
  }

  String _formatResult(double value) {
    if (!value.isFinite) {
      return 'Overflow';
    }
    if (value == 0) {
      return '0';
    }
    if (value % 1 == 0) {
      return value.toInt().toString();
    }
    final fixed = value.toStringAsFixed(10);
    return fixed
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final operatorText = _pendingOperator == null
        ? 'Ready'
        : '${_formatResult(_firstOperand!)} $_pendingOperator';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator Studio'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              children: [
                Icon(
                  widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  semanticLabel: widget.isDarkMode
                      ? 'Dark theme'
                      : 'Light theme',
                ),
                Switch(
                  key: const Key('theme_toggle'),
                  value: widget.isDarkMode,
                  onChanged: widget.onThemeChanged,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 720;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              color: colorScheme.surface,
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWide ? 820 : 430,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: isWide
                      ? Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: _CalculatorPanel(
                                display: _display,
                                status: _errorMessage ?? operatorText,
                                hasError: _hasError,
                                history: _history,
                                onDigit: _enterDigit,
                                onDecimal: _enterDecimal,
                                onOperator: _chooseOperator,
                                onEquals: _calculate,
                                onClearEntry: _clearEntry,
                                onAllClear: _allClear,
                                onDelete: _deleteLast,
                                onPercent: _applyPercent,
                                onSignToggle: _toggleSign,
                                onSquareRoot: _applySquareRoot,
                                onHistorySelected: _useHistoryResult,
                                onClearHistory: _clearHistory,
                              ),
                            ),
                          ],
                        )
                      : _CalculatorPanel(
                          display: _display,
                          status: _errorMessage ?? operatorText,
                          hasError: _hasError,
                          history: _history,
                          onDigit: _enterDigit,
                          onDecimal: _enterDecimal,
                          onOperator: _chooseOperator,
                          onEquals: _calculate,
                          onClearEntry: _clearEntry,
                          onAllClear: _allClear,
                          onDelete: _deleteLast,
                          onPercent: _applyPercent,
                          onSignToggle: _toggleSign,
                          onSquareRoot: _applySquareRoot,
                          onHistorySelected: _useHistoryResult,
                          onClearHistory: _clearHistory,
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({required this.expression, required this.result});

  final String expression;
  final String result;
}

class _CalculatorPanel extends StatelessWidget {
  const _CalculatorPanel({
    required this.display,
    required this.status,
    required this.hasError,
    required this.history,
    required this.onDigit,
    required this.onDecimal,
    required this.onOperator,
    required this.onEquals,
    required this.onClearEntry,
    required this.onAllClear,
    required this.onDelete,
    required this.onPercent,
    required this.onSignToggle,
    required this.onSquareRoot,
    required this.onHistorySelected,
    required this.onClearHistory,
  });

  final String display;
  final String status;
  final bool hasError;
  final List<_HistoryItem> history;
  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final ValueChanged<String> onOperator;
  final VoidCallback onEquals;
  final VoidCallback onClearEntry;
  final VoidCallback onAllClear;
  final VoidCallback onDelete;
  final VoidCallback onPercent;
  final VoidCallback onSignToggle;
  final VoidCallback onSquareRoot;
  final ValueChanged<_HistoryItem> onHistorySelected;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: hasError
                        ? colorScheme.errorContainer
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Text(
                          status,
                          key: const Key('status_text'),
                          textAlign: TextAlign.end,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: hasError
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Semantics(
                            label: 'Calculator display $display',
                            liveRegion: true,
                            child: Text(
                              display,
                              key: const Key('display_text'),
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(
                                    color: hasError
                                        ? colorScheme.onErrorContainer
                                        : colorScheme.onSurface,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 4,
                child: _HistoryPanel(
                  history: history,
                  onHistorySelected: onHistorySelected,
                  onClearHistory: onClearHistory,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          flex: 6,
          child: _ButtonGrid(
            onDigit: onDigit,
            onDecimal: onDecimal,
            onOperator: onOperator,
            onEquals: onEquals,
            onClearEntry: onClearEntry,
            onAllClear: onAllClear,
            onDelete: onDelete,
            onPercent: onPercent,
            onSignToggle: onSignToggle,
            onSquareRoot: onSquareRoot,
          ),
        ),
      ],
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({
    required this.history,
    required this.onHistorySelected,
    required this.onClearHistory,
  });

  final List<_HistoryItem> history;
  final ValueChanged<_HistoryItem> onHistorySelected;
  final VoidCallback onClearHistory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('History', style: Theme.of(context).textTheme.labelLarge),
                const Spacer(),
                IconButton(
                  key: const Key('clear_history_button'),
                  tooltip: 'Clear history',
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: history.isEmpty ? null : onClearHistory,
                ),
              ],
            ),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No history yet',
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    )
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = history[index];
                        return ListTile(
                          key: Key('history_item_$index'),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            item.expression,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(item.result),
                          onTap: () => onHistorySelected(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ButtonGrid extends StatelessWidget {
  const _ButtonGrid({
    required this.onDigit,
    required this.onDecimal,
    required this.onOperator,
    required this.onEquals,
    required this.onClearEntry,
    required this.onAllClear,
    required this.onDelete,
    required this.onPercent,
    required this.onSignToggle,
    required this.onSquareRoot,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final ValueChanged<String> onOperator;
  final VoidCallback onEquals;
  final VoidCallback onClearEntry;
  final VoidCallback onAllClear;
  final VoidCallback onDelete;
  final VoidCallback onPercent;
  final VoidCallback onSignToggle;
  final VoidCallback onSquareRoot;

  @override
  Widget build(BuildContext context) {
    final rows = <List<_CalcButtonData>>[
      [
        _CalcButtonData('AC', onPressed: onAllClear, type: _ButtonType.utility),
        _CalcButtonData(
          'CE',
          onPressed: onClearEntry,
          type: _ButtonType.utility,
        ),
        _CalcButtonData(
          'DEL',
          onPressed: onDelete,
          onLongPress: onAllClear,
          type: _ButtonType.utility,
        ),
        _CalcButtonData(
          '/',
          onPressed: () => onOperator('/'),
          type: _ButtonType.operator,
        ),
      ],
      [
        _CalcButtonData(
          'sqrt',
          onPressed: onSquareRoot,
          type: _ButtonType.operator,
        ),
        _CalcButtonData(
          '+/-',
          onPressed: onSignToggle,
          type: _ButtonType.operator,
        ),
        _CalcButtonData('%', onPressed: onPercent, type: _ButtonType.operator),
        _CalcButtonData(
          'x',
          onPressed: () => onOperator('x'),
          type: _ButtonType.operator,
        ),
      ],
      [
        for (final digit in ['7', '8', '9'])
          _CalcButtonData(digit, onPressed: () => onDigit(digit)),
        _CalcButtonData(
          '-',
          onPressed: () => onOperator('-'),
          type: _ButtonType.operator,
        ),
      ],
      [
        for (final digit in ['4', '5', '6'])
          _CalcButtonData(digit, onPressed: () => onDigit(digit)),
        _CalcButtonData(
          '+',
          onPressed: () => onOperator('+'),
          type: _ButtonType.operator,
        ),
      ],
      [
        for (final digit in ['1', '2', '3'])
          _CalcButtonData(digit, onPressed: () => onDigit(digit)),
        _CalcButtonData('=', onPressed: onEquals, type: _ButtonType.equals),
      ],
      [
        _CalcButtonData('0', onPressed: () => onDigit('0'), flex: 2),
        _CalcButtonData('.', onPressed: onDecimal),
        _CalcButtonData('=', onPressed: onEquals, type: _ButtonType.equals),
      ],
    ];

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          Expanded(
            child: Row(
              children: [
                for (
                  var itemIndex = 0;
                  itemIndex < rows[rowIndex].length;
                  itemIndex++
                ) ...[
                  Expanded(
                    flex: rows[rowIndex][itemIndex].flex,
                    child: _CalculatorButton(
                      data: rows[rowIndex][itemIndex],
                      id: '${rowIndex}_$itemIndex',
                    ),
                  ),
                  if (itemIndex != rows[rowIndex].length - 1)
                    const SizedBox(width: 10),
                ],
              ],
            ),
          ),
          if (rowIndex != rows.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

enum _ButtonType { number, operator, utility, equals }

class _CalcButtonData {
  const _CalcButtonData(
    this.label, {
    required this.onPressed,
    this.onLongPress,
    this.type = _ButtonType.number,
    this.flex = 1,
  });

  final String label;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final _ButtonType type;
  final int flex;
}

class _CalculatorButton extends StatelessWidget {
  const _CalculatorButton({required this.data, required this.id});

  final _CalcButtonData data;
  final String id;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = switch (data.type) {
      _ButtonType.number => (
        background: colorScheme.surfaceContainerHigh,
        foreground: colorScheme.onSurface,
      ),
      _ButtonType.operator => (
        background: colorScheme.primaryContainer,
        foreground: colorScheme.onPrimaryContainer,
      ),
      _ButtonType.utility => (
        background: colorScheme.secondaryContainer,
        foreground: colorScheme.onSecondaryContainer,
      ),
      _ButtonType.equals => (
        background: colorScheme.primary,
        foreground: colorScheme.onPrimary,
      ),
    };

    return Semantics(
      button: true,
      label: _semanticLabel(data.label),
      child: FilledButton(
        key: Key('calc_button_${data.label}_$id'),
        onPressed: data.onPressed,
        onLongPress: data.onLongPress,
        style: FilledButton.styleFrom(
          backgroundColor: colors.background,
          foregroundColor: colors.foreground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            data.label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: colors.foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  String _semanticLabel(String label) {
    return switch (label) {
      'AC' => 'All clear',
      'CE' => 'Clear entry',
      'DEL' => 'Delete last digit',
      '+/-' => 'Toggle sign',
      'sqrt' => 'Square root',
      '%' => 'Percent',
      '+' => 'Add',
      '-' => 'Subtract',
      'x' => 'Multiply',
      '/' => 'Divide',
      '=' => 'Equals',
      '.' => 'Decimal point',
      _ => label,
    };
  }
}
