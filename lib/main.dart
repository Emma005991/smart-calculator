import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const SmartCalculatorApp());
}

class SmartCalculatorApp extends StatefulWidget {
  const SmartCalculatorApp({super.key});

  @override
  State<SmartCalculatorApp> createState() => _SmartCalculatorAppState();
}

class _SmartCalculatorAppState extends State<SmartCalculatorApp> {
  bool dark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: MainNavigation(
        isDark: dark,
        onToggle: () => setState(() => dark = !dark),
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const MainNavigation({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      CalculatorHome(
        isDark: widget.isDark,
        onToggle: widget.onToggle,
        isScientific: false,
      ),
      CalculatorHome(
        isDark: widget.isDark,
        onToggle: widget.onToggle,
        isScientific: true,
      ),
      const UnitConverter(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.calculate), label: 'Basic'),
          NavigationDestination(icon: Icon(Icons.science), label: 'Scientific'),
          NavigationDestination(
            icon: Icon(Icons.straighten),
            label: 'Converter',
          ),
        ],
      ),
    );
  }
}

/* ---------- Calculator Home (Handles Basic & Scientific) ---------- */

class CalculatorHome extends StatefulWidget {
  final bool isDark;
  final bool isScientific;
  final VoidCallback onToggle;

  const CalculatorHome({
    super.key,
    required this.isDark,
    required this.onToggle,
    required this.isScientific,
  });

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String expr = "";
  String result = "";

  void _press(String v) => setState(() => expr += v);
  void _clear() => setState(() {
    expr = "";
    result = "";
  });
  void _back() => setState(() {
    if (expr.isNotEmpty) expr = expr.substring(0, expr.length - 1);
  });

  void _equals() {
    try {
      final r = evaluate(expr);
      setState(() {
        result = r;
        expr = r;
      });
    } catch (_) {
      setState(() => result = "Error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final basicButtons = [
      "C",
      "(",
      ")",
      "⌫",
      "7",
      "8",
      "9",
      "/",
      "4",
      "5",
      "6",
      "*",
      "1",
      "2",
      "3",
      "-",
      "0",
      ".",
      "%",
      "+",
    ];
    final sciButtons = ["^", "√", "π", "sin", "cos", "tan"];
    final buttons = widget.isScientific
        ? [...sciButtons, ...basicButtons]
        : basicButtons;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isScientific ? "Scientific" : "Calculator"),
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggle,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(expr, style: const TextStyle(fontSize: 36)),
                  ),
                  Text(
                    result,
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          GridView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.isScientific ? 5 : 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: buttons.length + 1,
            itemBuilder: (context, i) {
              if (i < buttons.length) {
                return ElevatedButton(
                  onPressed: () {
                    if (buttons[i] == "C") return _clear();
                    if (buttons[i] == "⌫") return _back();
                    _press(buttons[i]);
                  },
                  child: Text(buttons[i]),
                );
              }
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                ),
                onPressed: _equals,
                child: const Text("="),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* ---------- Unit Converter ---------- */

class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  double inputVal = 1.0;
  String fromUnit = "Meters";
  String toUnit = "Feet";

  final Map<String, double> lengthUnits = {
    "Meters": 1.0,
    "Feet": 3.28084,
    "Inches": 39.3701,
    "KM": 0.001,
    "Miles": 0.000621371,
  };

  double get convertedValue {
    double inMeters = inputVal / lengthUnits[fromUnit]!;
    return inMeters * lengthUnits[toUnit]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Unit Converter (Length)")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter Value",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  setState(() => inputVal = double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: fromUnit,
                  items: lengthUnits.keys
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => fromUnit = v!),
                ),
                const Icon(Icons.arrow_forward),
                DropdownButton<String>(
                  value: toUnit,
                  items: lengthUnits.keys
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (v) => setState(() => toUnit = v!),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              "${convertedValue.toStringAsFixed(4)} $toUnit",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------- Updated Math Engine ---------- */

String evaluate(String input) {
  if (input.isEmpty) return "0";
  String s = input.replaceAll('π', math.pi.toString());

  // Basic tokenizing for Scientific
  // Note: For production, a proper library like 'expressions' or 'math_expressions' is recommended.
  // This is a simplified manual parser.
  try {
    if (s.contains('√')) {
      final num = double.parse(s.replaceAll('√', ''));
      return math.sqrt(num).toStringAsFixed(4);
    }
    // Simple eval for standard math
    final tokens = tokenize(s);
    final postfix = toPostfix(tokens);
    final value = evalPostfix(postfix);

    return (value % 1 == 0)
        ? value.toInt().toString()
        : value.toStringAsFixed(4);
  } catch (e) {
    return "Error";
  }
}

// Reuse the tokenize, toPostfix, and evalPostfix from previous response...
// (Ensure prec() includes '^' with priority 3)
int prec(String o) {
  if (o == "^") return 3;
  if (o == "*" || o == "/") return 2;
  if (o == "+" || o == "-") return 1;
  return 0;
}

List<String> tokenize(String s) {
  final List<String> t = [];
  String n = "";
  for (int i = 0; i < s.length; i++) {
    final c = s[i];
    if ("0123456789.".contains(c)) {
      n += c;
    } else {
      if (n.isNotEmpty) {
        t.add(n);
        n = "";
      }
      if ("+-*/()^".contains(c)) t.add(c);
    }
  }
  if (n.isNotEmpty) t.add(n);
  return t;
}

List<String> toPostfix(List<String> t) {
  final out = <String>[];
  final st = <String>[];
  for (final x in t) {
    if (double.tryParse(x) != null) {
      out.add(x);
    } else if (x == "(") {
      st.add(x);
    } else if (x == ")") {
      while (st.isNotEmpty && st.last != "(") out.add(st.removeLast());
      st.removeLast();
    } else {
      while (st.isNotEmpty && prec(st.last) >= prec(x))
        out.add(st.removeLast());
      st.add(x);
    }
  }
  while (st.isNotEmpty) out.add(st.removeLast());
  return out;
}

double evalPostfix(List<String> p) {
  final st = <double>[];
  for (final x in p) {
    final val = double.tryParse(x);
    if (val != null) {
      st.add(val);
    } else {
      final b = st.removeLast();
      final a = st.removeLast();
      switch (x) {
        case "+":
          st.add(a + b);
          break;
        case "-":
          st.add(a - b);
          break;
        case "*":
          st.add(a * b);
          break;
        case "/":
          st.add(a / b);
          break;
        case "^":
          st.add(math.pow(a, b).toDouble());
          break;
      }
    }
  }
  return st.single;
}
