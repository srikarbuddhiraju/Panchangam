import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Saffron-based Material 3 theme for the Panchangam app.
///
/// Seed color: Saffron — Color(0xFFFF6F00)
/// Brand colors exposed as constants for use in widget code.
class AppTheme {
  AppTheme._();

  // ── Brand colours ─────────────────────────────────────────────────────────
  static const Color kSaffron = Color(0xFFFF6F00); // Primary seed
  static const Color kGold = Color(0xFFFFB300); // Highlight, borders
  static const Color kKumkum = Color(0xFFB71C1C); // Deep red — Krishna Paksha
  static const Color kRahuKalamRed = Color(0xFFD32F2F); // Rahu Kalam bars
  static const Color kAuspiciousGreen = Color(0xFF2E7D32); // Abhijit, Amrit
  static const Color kFestivalAmber = Color(0xFFFFA000); // Festival day border

  // ── Base text style ───────────────────────────────────────────────────────
  static TextTheme _buildTextTheme(Brightness brightness) {
    final TextTheme base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;
    // Use Noto Sans Telugu for all text — renders both Telugu and Latin well
    return GoogleFonts.notoSansTeluguTextTheme(base);
  }

  // ── Light theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kSaffron,
          brightness: Brightness.light,
        ),
        textTheme: _buildTextTheme(Brightness.light),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: const Color(0xFFFFF8E1), // warm cream
          foregroundColor: const Color(0xFF4A3000),
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: GoogleFonts.notoSansTelugu(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF4A3000),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: kSaffron,
          unselectedItemColor: Colors.grey.shade500,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.notoSansTelugu(fontSize: 11),
          unselectedLabelStyle: GoogleFonts.notoSansTelugu(fontSize: 11),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFFF8E1),
          labelStyle: GoogleFonts.notoSansTelugu(fontSize: 12),
        ),
      );

  // ── Dark theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kSaffron,
          brightness: Brightness.dark,
        ),
        textTheme: _buildTextTheme(Brightness.dark),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: const Color(0xFF1A1200),
          foregroundColor: const Color(0xFFFFE082),
          elevation: 0,
          scrolledUnderElevation: 1,
          titleTextStyle: GoogleFonts.notoSansTelugu(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFFFE082),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: kGold,
          unselectedItemColor: Colors.grey.shade600,
          backgroundColor: const Color(0xFF1A1200),
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: GoogleFonts.notoSansTelugu(fontSize: 11),
          unselectedLabelStyle: GoogleFonts.notoSansTelugu(fontSize: 11),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF3A2800)),
          ),
        ),
      );
}
