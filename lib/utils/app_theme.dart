import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Pro Color Palette
  static const Color primaryColor = Color(0xFF045D56); // Deep Emerald
  static const Color secondaryColor = Color(0xFFD4AF37); // Gold
  static const Color accentColor = Color(0xFFE5C15D); // Lighter Gold

  // Surface Colors
  static const Color lightSurface = Color(0xFFF8F5F2); // Warm Cream
  static const Color darkSurface = Color(0xFF1A1A1A); // Deep Night
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF2C2C2C);

  static ThemeData lightTheme(String? fontFamily) {
    return _buildTheme(
      brightness: Brightness.light,
      baseColor: primaryColor,
      surface: lightSurface,
      cardColor: cardLight,
      fontFamily: fontFamily,
    );
  }

  static ThemeData darkTheme(String? fontFamily) {
    return _buildTheme(
      brightness: Brightness.dark,
      baseColor: primaryColor,
      surface: darkSurface,
      cardColor: cardDark,
      fontFamily: fontFamily,
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color baseColor,
    required Color surface,
    required Color cardColor,
    String? fontFamily,
  }) {
    final baseTextTheme = GoogleFonts.latoTextTheme();

    TextTheme headingsTextTheme;
    switch (fontFamily) {
      case 'Noto Naskh Arabic':
        headingsTextTheme = GoogleFonts.notoNaskhArabicTextTheme();
        break;
      case 'Aref Ruqaa':
        headingsTextTheme = GoogleFonts.arefRuqaaTextTheme();
        break;
      case 'Cairo':
        headingsTextTheme = GoogleFonts.cairoTextTheme();
        break;
      case 'Lateef':
        headingsTextTheme = GoogleFonts.lateefTextTheme();
        break;
      case 'Amiri':
      default:
        headingsTextTheme = GoogleFonts.amiriTextTheme();
        break;
    }
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: baseColor,
        primary: isDark
            ? accentColor
            : baseColor, // Use accent gold/lighter green for dark mode primary
        secondary: secondaryColor,
        surface: surface,
        onSurface: isDark ? Colors.white : Colors.black87,
        brightness: brightness,
      ),
      scaffoldBackgroundColor: surface,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: surface,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        titleTextStyle: headingsTextTheme.headlineSmall?.copyWith(
          color: isDark ? secondaryColor : baseColor,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: isDark ? secondaryColor : baseColor),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 10,
        backgroundColor: cardColor,
        indicatorColor: isDark
            ? secondaryColor.withOpacity(0.2)
            : baseColor.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: isDark ? secondaryColor : baseColor);
          }
          return IconThemeData(color: Colors.grey.shade600);
        }),
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: headingsTextTheme.displayLarge?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        displayMedium: headingsTextTheme.displayMedium?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        displaySmall: headingsTextTheme.displaySmall?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        headlineLarge: headingsTextTheme.headlineLarge?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        headlineMedium: headingsTextTheme.headlineMedium?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        headlineSmall: headingsTextTheme.headlineSmall?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleLarge: headingsTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleMedium: headingsTextTheme.titleMedium?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleSmall: headingsTextTheme.titleSmall?.copyWith(
          color: isDark ? Colors.white : Colors.black87,
        ),
        bodyLarge: headingsTextTheme.bodyLarge?.copyWith(
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        bodyMedium: headingsTextTheme.bodyMedium?.copyWith(
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        bodySmall: headingsTextTheme.bodySmall?.copyWith(
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      ),
    );
  }
}
