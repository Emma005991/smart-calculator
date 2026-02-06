
---

# 🚀 Smart Multi Calculator

A sleek, modern, and feature rich calculator built with **Flutter** and **Dart**. This app goes beyond simple arithmetic, offering a comprehensive suite for scientific calculations and unit conversions with a focus on clean UI/UX.

## ✨ Key Features

* **Standard Calculator:** Fast and reliable basic arithmetic with history tracking.
* **Scientific Mode:** Support for advanced operations including square roots (), exponents (), trigonometric functions (), and constants ().
* **Unit Converter:** Seamlessly convert lengths (Meters, Feet, Inches, KM, Miles) with real-time results.
* **Dynamic UI:** * 🌗 **Dark/Light Mode:** Toggle between themes for comfort.
* 📱 **Responsive Grid:** Adapts layout based on calculation mode.
* 📊 **History Log:** Keep track of your previous calculations.


* **Custom Math Engine:** Built using a custom Shunting yard algorithm for reliable expression parsing.

---

## 🛠️ Technical Stack

* **Framework:** [Flutter](https://flutter.dev)
* **Language:** [Dart](https://dart.dev)
* **State Management:** `StatefulWidget` (State driven UI)
* **Algorithm:** Custom Postfix (Reverse Polish Notation) evaluator.

---

## 📸 Screenshots

| Standard Mode | Scientific Mode | Unit Converter |
| --- | --- | --- |
|  |  |  |

---

## ⚙️ How It Works

The calculator uses a two step process to handle complex mathematical expressions:

1. **Tokenization:** Breaks the input string into numbers and operators.
2. **Shunting-yard Algorithm:** Converts the infix notation (e.g., ) into postfix notation () to respect mathematical operator precedence.

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK installed on your machine.
* Android Studio / VS Code / Xcode.

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/your-username/smart-calculator.git

```


2. **Navigate to the project directory:**
```bash
cd smart-calculator

```


3. **Install dependencies:**
```bash
flutter pub get

```


4. **Run the app:**
```bash
flutter run

```






