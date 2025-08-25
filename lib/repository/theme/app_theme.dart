import 'package:flutter/material.dart';

class AppColors {
  static const maroon = Color(0xFF730000);
  static const gold = Color(0xFFF9ECD1);
  static const darkGold = Color(0xFF937C3A);
  static const buyPrice = Color(0xFF9E1C1C);
  static const sellPrice = Color(0xFF008F3D);
  static const boxBg = Color(0xFFFDF8EF);
  static const appBarMaroon = Color(0xFF730000);
  static const cardGrayColor = Color.fromARGB(255, 206, 204, 198);
}

enum AppTheme { maroonGoldLight, maroonGoldDark }

abstract class ThemeStyle {
  ThemeData? get themeData;
  Color? get drawerGradientStartColor;
  Color? get drawerGradientEndColor;
}

class AppThemeStyle extends ThemeStyle {
  final ThemeData? _themeData;
  final Color? _drawerGradientStartColor;
  final Color? _drawerGradientEndColor;

  AppThemeStyle({
    ThemeData? themeData,
    Color? drawerGradientStartColor,
    Color? drawerGradientEndColor,
  }) : _themeData = themeData,
       _drawerGradientStartColor = drawerGradientStartColor,
       _drawerGradientEndColor = drawerGradientEndColor;

  @override
  ThemeData? get themeData => _themeData;

  @override
  Color? get drawerGradientStartColor => _drawerGradientStartColor;

  @override
  Color? get drawerGradientEndColor => _drawerGradientEndColor;
}

final appThemeData = {
  AppTheme.maroonGoldLight: ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.maroon,
    scaffoldBackgroundColor: AppColors.boxBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.appBarMaroon,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkGold,
      foregroundColor: Colors.white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.darkGold,
        foregroundColor: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardColor: AppColors.gold,
    dividerColor: AppColors.darkGold,
    iconTheme: const IconThemeData(color: AppColors.maroon),
    primaryTextTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gold,
      border: OutlineInputBorder(),
    ),
  ),

  AppTheme.maroonGoldDark: ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.darkGold,
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.maroon,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.darkGold,
      foregroundColor: Colors.white,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: AppColors.darkGold,
        foregroundColor: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.maroon,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    cardColor: Colors.grey[900],
    dividerColor: Colors.white30,
    iconTheme: const IconThemeData(color: AppColors.gold),
    primaryTextTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.black12,
      border: OutlineInputBorder(),
    ),
  ),
};
