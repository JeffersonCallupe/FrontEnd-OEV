import 'package:flutter/material.dart';

const colorList = <Color>[
  Color(0xFF0177FB),
  Colors.red,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.yellow,
  Colors.pink,
  Colors.teal,
  Colors.cyan,
  Colors.indigo,
];

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
      : assert(selectedColor >= 0, 'selectedColor must be greater than or equal to 0'),
        assert(selectedColor < colorList.length, 'selectedColor must be less than ${colorList.length}');

  ThemeData getTheme() => ThemeData(
        fontFamily: 'Inter',
        useMaterial3: true,
        colorSchemeSeed: colorList[selectedColor],
        appBarTheme: const AppBarTheme(
          centerTitle: false,
        ),
      );
}