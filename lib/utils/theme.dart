import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Color tokens ─────────────────────────────────────────────────
class C {
  static const bg      = Color(0xFF0A0A12);
  static const bg2     = Color(0xFF111120);
  static const card    = Color(0xFF16162A);
  static const card2   = Color(0xFF1E1E34);
  static const border  = Color(0xFF28284A);
  static const orange  = Color(0xFFFF6B00);
  static const orangeL = Color(0xFFFF8C38);
  static const amber   = Color(0xFFFFB300);
  static const red     = Color(0xFFFF3B3B);
  static const green   = Color(0xFF28C76F);
  static const greenL  = Color(0xFF48E990);
  static const blue    = Color(0xFF00B4D8);
  static const purple  = Color(0xFF7C5CBF);
  static const teal    = Color(0xFF00C9A7);
  static const gold    = Color(0xFFFFD700);
  static const text    = Color(0xFFECEAFF);
  static const text2   = Color(0xFF8886A8);
  static const text3   = Color(0xFF45435E);
  static const white   = Colors.white;

  static LinearGradient get brandGrad => const LinearGradient(
    colors: [Color(0xFFFF6B00), Color(0xFFFF9500)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static LinearGradient get cardGrad => const LinearGradient(
    colors: [Color(0xFF16162A), Color(0xFF1E1E34)],
    begin: Alignment.topLeft, end: Alignment.bottomRight);

  static List<BoxShadow> glow(Color c, {double b = 12}) =>
      [BoxShadow(color: c.withOpacity(.38), blurRadius: b, spreadRadius: 1)];

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
        primary: orange, secondary: amber, surface: card),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
        .apply(bodyColor: text, displayColor: text),
    appBarTheme: const AppBarTheme(
        backgroundColor: bg, foregroundColor: text,
        elevation: 0, centerTitle: false),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card2,
      labelStyle: const TextStyle(color: text2),
      hintStyle: const TextStyle(color: text3),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: orange, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    dividerColor: border,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: orange, foregroundColor: white),
    chipTheme: ChipThemeData(
      backgroundColor: card2, side: const BorderSide(color: border),
      labelStyle: const TextStyle(fontSize: 12, color: text2)),
  );
}
