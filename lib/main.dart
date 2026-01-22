import 'package:flutter/material.dart';
import 'dart:math';

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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: CalculatorHome(
        isDark: dark,
        onToggle: () => setState(() => dark = !dark),
      ),
    );
  }
}

class CalculatorHome extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const CalculatorHome({
    super.key,
    required this.isDark,
    required this.onToggle,
  });

  @override
  State<CalculatorHome> createState() => _CalculatorHomeState();
}

class _CalculatorHomeState extends State<CalculatorHome> {
  String expr = "";
  String result = "";
  final List<String> history = [];

  void _press(String v) {
    setState(() => expr += v);
  }

  void _clear() {
    setState(() {
      expr = "";
      result = "";
    });
  }

  void _back() {
    if (expr.isNotEmpty) {
      setState(() => expr = expr.substring(0, expr.length - 1));
    }
  }

  void _equals() {
    try {
      final r = evaluate(expr);
      setState(() {
        result = r;
        history.insert(0, "$expr = $r");
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
      builder: (_) => SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: history.isEmpty
                  ? const Center(child: Text("No history yet"))
                  : ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (_, i) => ListTile(title: Text(history[i])),
                    ),
            ),
            TextButton(
              onPressed: () {
                setState(() => history.clear());
                Navigator.pop(context);
              },
              child: const Text("Clear History"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttons = [
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Calculator"),
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
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.bottomRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(expr, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(
                  result,
                  style: const TextStyle(fontSize: 20, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              padding: const EdgeInsets.all(12),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                for (final b in buttons)
                  ElevatedButton(
                    onPressed: () {
                      if (b == "C") return _clear();
                      if (b == "⌫") return _back();
                      _press(b);
                    },
                    child: Text(b, style: const TextStyle(fontSize: 20)),
                  ),
                ElevatedButton(
                  onPressed: _equals,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 60),
                  ),
                  child: const Text("=", style: TextStyle(fontSize: 24)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------- Expression Engine ---------- */

String evaluate(String input) {
  if (input.trim().isEmpty) return "0";

  // convert % : 50% -> (50/100)
  final percent = RegExp(r'(\d+(\.\d+)?)%');
  String s = input.replaceAllMapped(percent, (m) => "(${m[1]}/100)");

  final tokens = tokenize(s);
  final postfix = toPostfix(tokens);
  final value = evalPostfix(postfix);
  if (value.isNaN || value.isInfinite) throw Exception();
  return value
      .toStringAsFixed(value.truncateToDouble() == value ? 0 : 4)
      .replaceAll(RegExp(r'0+$'), '')
      .replaceAll(RegExp(r'\.$'), '');
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
      if ("+-*/()".contains(c)) t.add(c);
    }
  }
  if (n.isNotEmpty) t.add(n);
  return t;
}

int prec(String o) => (o == "+" || o == "-")
    ? 1
    : (o == "*" || o == "/")
    ? 2
    : 0;

List<String> toPostfix(List<String> t) {
  final out = <String>[];
  final st = <String>[];
  for (final x in t) {
    if (double.tryParse(x) != null) {
      out.add(x);
    } else if ("+-*/".contains(x)) {
      while (st.isNotEmpty && prec(st.last) >= prec(x)) {
        out.add(st.removeLast());
      }
      st.add(x);
    } else if (x == "(") {
      st.add(x);
    } else if (x == ")") {
      while (st.isNotEmpty && st.last != "(") {
        out.add(st.removeLast());
      }
      st.removeLast();
    }
  }
  while (st.isNotEmpty) out.add(st.removeLast());
  return out;
}

double evalPostfix(List<String> p) {
  final st = <double>[];
  for (final x in p) {
    if (double.tryParse(x) != null) {
      st.add(double.parse(x));
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
      }
    }
  }
  return st.single;
}
