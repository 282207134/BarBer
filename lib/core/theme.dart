import 'package:flutter/material.dart';

const ink = Color(0xFF202020),
    orange = Color(0xFFF4552F),
    muted = Color(0xFF858589),
    pale = Color(0xFFF1F1F1),
    gold = Color(0xFFFFCC46);
TextStyle display(double size, [Color color = ink]) => TextStyle(
  fontFamily: 'ArchivoBlack',
  fontSize: size,
  color: color,
  height: 1.15,
);
ThemeData get appTheme => ThemeData(
  useMaterial3: true,
  fontFamily: 'Roboto',
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: orange,
    primary: orange,
    surface: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16, color: ink),
    bodyLarge: TextStyle(fontSize: 17, color: ink),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFD8D8DC),
    thickness: 1,
    space: 30,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    centerTitle: true,
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: ink,
    behavior: SnackBarBehavior.floating,
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: orange,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 58),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
    ),
  ),
);
