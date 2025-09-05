import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_shell.dart';
import 'theme/design_system.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: DesignSystem.primaryColor,
      brightness: Brightness.light,
      surface: const Color(0xFFFEF7FF),
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: DesignSystem.primaryColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF141218),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: lightScheme.surface,
      textTheme: DesignSystem.textTheme.apply(
        bodyColor: lightScheme.onSurface,
        displayColor: lightScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightScheme.surface,
        foregroundColor: lightScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: lightScheme.onSurface,
        ),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: lightScheme.primary,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: darkScheme.surface,
      textTheme: DesignSystem.textTheme.apply(
        bodyColor: darkScheme.onSurface,
        displayColor: darkScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkScheme.surface,
        foregroundColor: darkScheme.onSurface,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkScheme.onSurface,
        ),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.symmetric(vertical: 8),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: darkScheme.primary,
      ),
    );

    return ProviderScope(
      child: MaterialApp(
        title: 'Daily Tracker',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const AppShell(),
      ),
    );
  }
}
