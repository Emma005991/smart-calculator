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
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
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

/* ---------- Calculator Home with History ---------- */

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
  final List<String> history = [];

  void _press(String v) => setState(() => expr += v);
  void _clear() => setState(() {
    expr = "";
    result = "";
  });
  void _back() => setState(() {
    if (expr.isNotEmpty) expr = expr.substring(0, expr.length - 1);
  });

  void _equals() {
    if (expr.isEmpty) return;
    try {
      final r = evaluate(expr);
      setState(() {
        history.insert(0, "$expr = $r");
        result = r;
        expr = r;
      });
    } catch (_) {
      setState(() => result = "Error");
    }
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "History",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    history.clear();
                    Navigator.pop(context);
                  }),
                  child: const Text("Clear All"),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text("No calculations yet"))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, i) => ListTile(
                        title: Text(history[i]),
                        onTap: () {
                          setState(() => expr = history[i].split(' = ')[1]);
                          Navigator.pop(context);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
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
    final sciButtons = ["sin", "cos", "tan", "√", "^", "π"];
    final buttons = widget.isScientific
        ? [...sciButtons, ...basicButtons]
        : basicButtons;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.isScientific ? "Scientific" : "Calculator"),
        actions: [
          IconButton(icon: const Icon(Icons.history), onPressed: _showHistory),
          IconButton(
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggle,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
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
                  const SizedBox(height: 10),
                  Text(
                    result,
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 5,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const ClampingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.isScientific ? 5 : 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: widget.isScientific ? 1.1 : 1.0,
              ),
              itemCount: buttons.length + 1,
              itemBuilder: (context, i) {
                bool isLast = i == buttons.length;
                String label = isLast ? "=" : buttons[i];

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: EdgeInsets.zero,
                    backgroundColor: isLast
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                  ),
                  onPressed: () {
                    if (isLast) return _equals();
                    if (label == "C") return _clear();
                    if (label == "⌫") return _back();
                    _press(label);
                  },
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: widget.isScientific ? 15 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
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
      appBar: AppBar(title: const Text("Unit Converter")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Value",
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

/* ---------- Math Engine ---------- */

String evaluate(String input) {
  if (input.isEmpty) return "0";
  String s = input.replaceAll('π', math.pi.toString());

  try {
    final sciRegex = RegExp(r'(sin|cos|tan|√)(\d+\.?\d*)');
    s = s.replaceAllMapped(sciRegex, (match) {
      String func = match.group(1)!;
      double val = double.parse(match.group(2)!);
      double rad = val * (math.pi / 180);

      switch (func) {
        case 'sin':
          return math.sin(rad).toString();
        case 'cos':
          return math.cos(rad).toString();
        case 'tan':
          return math.tan(rad).toString();
        case '√':
          return math.sqrt(val).toString();
        default:
          return val.toString();
      }
    });

    final tokens = tokenize(s);
    final postfix = toPostfix(tokens);
    final value = evalPostfix(postfix);

    if (value.isNaN || value.isInfinite) return "Error";

    if (value % 1 == 0) {
      return value.toInt().toString();
    } else {
      return value
          .toStringAsFixed(4)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  } catch (e) {
    return "Error";
  }
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
      if ("+-*/()^%".contains(c)) t.add(c);
    }
  }
  if (n.isNotEmpty) t.add(n);
  return t;
}

int prec(String o) {
  if (o == "^") return 3;
  if (o == "*" || o == "/" || o == "%") return 2;
  if (o == "+" || o == "-") return 1;
  return 0;
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
      if (st.isNotEmpty) st.removeLast();
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
      if (st.length < 2) continue;
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
        case "%":
          st.add(a % b);
          break;
        case "^":
          st.add(math.pow(a, b).toDouble());
          break;
      }
    }
  }
  return st.isEmpty ? 0 : st.single;
}
