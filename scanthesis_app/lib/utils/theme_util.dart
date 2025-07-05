import 'package:flutter/material.dart';
import 'style_util.dart';

class ThemeUtil {
  static final ThemeData globalDarkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: StyleUtil.darkScaffoldBackground,
    colorScheme: const ColorScheme.dark(
      primary: StyleUtil.primaryColor,
      secondary: StyleUtil.secondaryColor,
      surface: StyleUtil.darkSurfaceColor,
      onSurface: StyleUtil.darkOnSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: StyleUtil.darkOnSecondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: StyleUtil.darkSurfaceColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: StyleUtil.primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        elevation: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: StyleUtil.inputFillDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: StyleUtil.primaryColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: StyleUtil.primaryColor),
      ),
      labelStyle: const TextStyle(color: StyleUtil.primaryColor),
      hintStyle: const TextStyle(color: Colors.white60),
    ),
    textTheme: ThemeData.dark().textTheme.copyWith(
      titleLarge: ThemeData.dark().textTheme.titleLarge?.copyWith(
        color: Colors.white,
      ),
      bodyMedium: ThemeData.dark().textTheme.bodyMedium?.copyWith(
        color: Colors.white70,
      ),
      labelLarge: ThemeData.dark().textTheme.labelLarge?.copyWith(
        color: StyleUtil.primaryColor,
      ),
    ),
    iconTheme: const IconThemeData(color: StyleUtil.iconLight),
    dividerTheme: const DividerThemeData(color: StyleUtil.dividerDark),
    cardColor: StyleUtil.darkSurfaceColor,
  );

  static final ThemeData globalLightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: StyleUtil.lightScaffoldBackground,
    primaryColor: StyleUtil.primaryColor,
    colorScheme: const ColorScheme.light(
      primary: StyleUtil.primaryColor,
      secondary: StyleUtil.secondaryColor,
      surface: StyleUtil.lightSurfaceColor,
      onSurface: StyleUtil.lightOnSurfaceColor,
      onPrimary: Colors.white,
      onSecondary: StyleUtil.lightOnSecondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: StyleUtil.lightSurfaceColor,
      elevation: 0,
      foregroundColor: StyleUtil.lightOnSurfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: StyleUtil.primaryColor,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: StyleUtil.inputFillLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: StyleUtil.primaryColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: StyleUtil.primaryColor),
      ),
      labelStyle: const TextStyle(color: StyleUtil.primaryColor),
    ),
    textTheme: ThemeData.light().textTheme.copyWith(
      titleLarge: ThemeData.light().textTheme.titleLarge?.copyWith(
        color: StyleUtil.lightOnSurfaceColor,
      ),
      bodyMedium: ThemeData.light().textTheme.bodyMedium?.copyWith(
        color: StyleUtil.lightOnSurfaceColor,
      ),
      labelLarge: ThemeData.light().textTheme.labelLarge?.copyWith(
        color: StyleUtil.primaryColor,
      ),
    ),
    iconTheme: const IconThemeData(color: StyleUtil.iconDark),
  );
}
