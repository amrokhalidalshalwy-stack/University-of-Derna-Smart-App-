import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF4C6EF5),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFF4C6EF5),
    secondary: Color(0xFF4C6EF5),
  ),
  scaffoldBackgroundColor: const Color(0xFF18191A),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF4C6EF5),
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF2A2A2A),
    selectedItemColor: Color(0xFF4C6EF5),
    unselectedItemColor: Colors.grey,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFF2A2A2A),
    indicatorColor: Color(0xFF4C6EF5),
    labelTextStyle: WidgetStatePropertyAll(TextStyle(color: Colors.white)),
    iconTheme: WidgetStatePropertyAll(IconThemeData(color: Colors.white)),
  ),

  iconTheme: const IconThemeData(color: Colors.white),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
  cardColor: const Color(0xFF2A2A2A),

  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Color(0xFF3A3B3C),
    filled: true,
    hintStyle: TextStyle(color: Colors.grey),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF4C6EF5), width: 2),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4C6EF5),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
    ),
  ),
);
