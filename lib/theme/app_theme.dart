import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class C {
  static const navy = Color(0xFF0D1B3E);
  static const royal = Color(0xFF1A3A6E);
  static const blue = Color(0xFF0369A1); // accessible high-contrast accent (WCAG AA on white)
  static const gold = Color(0xFFC9A84C);
  static const bg = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE2E8F0);
  static const text = Color(0xFF0F172A); // near-black slate for AAA body contrast
  static const muted = Color(0xFF475569); // darkened for 4.5:1 on white
  static const danger = Color(0xFFDC2626);
  static const warning = Color(0xFFEA580C);
  static const success = Color(0xFF16A34A);
  static const info = Color(0xFF0369A1);

  /// EB Garamond serif — for institutional headings/titles.
  static TextStyle serif({
    double size = 18,
    FontWeight weight = FontWeight.w700,
    Color color = navy,
    double height = 1.2,
    double letterSpacing = 0,
  }) => GoogleFonts.ebGaramond(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: C.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: C.royal,
        brightness: Brightness.light,
        primary: C.royal,
        secondary: C.gold,
        surface: C.card,
      ),
    );

    // Lato body throughout; EB Garamond reserved for display/headline roles.
    final textTheme = GoogleFonts.latoTextTheme(base.textTheme).copyWith(
      displayLarge:  GoogleFonts.ebGaramond(textStyle: base.textTheme.displayLarge,  color: C.navy, fontWeight: FontWeight.w700),
      displayMedium: GoogleFonts.ebGaramond(textStyle: base.textTheme.displayMedium, color: C.navy, fontWeight: FontWeight.w700),
      displaySmall:  GoogleFonts.ebGaramond(textStyle: base.textTheme.displaySmall,  color: C.navy, fontWeight: FontWeight.w700),
      headlineMedium: GoogleFonts.ebGaramond(textStyle: base.textTheme.headlineMedium, color: C.navy, fontWeight: FontWeight.w700),
      headlineSmall:  GoogleFonts.ebGaramond(textStyle: base.textTheme.headlineSmall,  color: C.navy, fontWeight: FontWeight.w700),
    ).apply(bodyColor: C.text, displayColor: C.navy);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: C.navy,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: C.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: C.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: C.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: C.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: C.blue, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: C.danger),
        ),
        hintStyle: const TextStyle(color: C.muted, fontSize: 13),
        labelStyle: const TextStyle(color: C.muted, fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: C.royal,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: C.royal,
          side: const BorderSide(color: C.border),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: C.royal),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: C.navy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
