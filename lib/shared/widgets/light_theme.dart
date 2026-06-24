import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFB8860B),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFB8860B),
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.white,

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFB8860B),
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFF2F4F2),
    selectedItemColor: Color(0xFFB8860B),
    unselectedItemColor: Colors.grey,
  ),

  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Color(0xFFF2F4F2),
    indicatorColor: Color(0xFFB8860B),
    labelTextStyle: WidgetStatePropertyAll(TextStyle(color: Colors.black)),
    iconTheme: WidgetStatePropertyAll(IconThemeData(color: Colors.black)),
  ),

  iconTheme: const IconThemeData(color: Colors.black),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.black)),

  inputDecorationTheme: const InputDecorationTheme(
    fillColor: Color(0xFFF2F4F2),
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
      borderSide: BorderSide(color: Color(0xFFB8860B), width: 2),
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFB8860B),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
    ),
  ),
);
