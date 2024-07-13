import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyThemeData {
  static const lightPrimaryColor = Color(0xFF41966F);
  static const lightAccentColor = Color(0xFF52BF95);
  static const darkPrimaryColor = Color(0xFF141A2E);
  static const darkAccentColor = Color(0xFF0F8C5F);
  static const lightMainTextColor = Color(0xFF000000);
  static const darkMainTextColor = Color(0xFFFFFFFF);

  static var lightTheme = ThemeData(
      primaryColorLight: lightPrimaryColor,
      canvasColor: lightAccentColor,
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: lightAccentColor),
      cardTheme: const CardTheme(color: Colors.white),
      primaryColor: lightPrimaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.black54),
      appBarTheme:
          const AppBarTheme(color: Colors.transparent, centerTitle: true),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: lightPrimaryColor,
          selectedItemColor: Colors.black54,
          unselectedItemColor: Colors.white),
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: lightMainTextColor,
        ),
        titleMedium: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: lightMainTextColor,
        ),
        titleSmall: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: lightMainTextColor,
        ),
        bodyLarge: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.normal,
          color: lightMainTextColor,
        ),
        bodyMedium: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
          color: lightMainTextColor,
        ),
        bodySmall: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.normal,
          color: lightMainTextColor,
        ),
      ));

  static var darkTheme = ThemeData(
      primaryColorDark: darkPrimaryColor,
      canvasColor: darkAccentColor,
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: darkAccentColor),
      cardTheme: const CardTheme(color: darkPrimaryColor),
      primaryColor: darkPrimaryColor,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(color: darkAccentColor),
          color: Colors.transparent,
          centerTitle: true),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: darkPrimaryColor,
          selectedItemColor: darkAccentColor,
          unselectedItemColor: Colors.white),
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: TextTheme(
        headline3: TextStyle(
          fontSize: 32.sp,
          fontWeight: FontWeight.bold,
          color: darkMainTextColor,
        ),
        headline5: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: darkMainTextColor,
        ),
        bodyText1: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.normal,
          color: darkMainTextColor,
        ),
        bodyText2: TextStyle(
          fontSize: 19.sp,
          fontWeight: FontWeight.normal,
          color: darkMainTextColor,
        ),
      ));
}
