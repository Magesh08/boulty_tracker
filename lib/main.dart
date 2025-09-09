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
      surface: Colors.white,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: DesignSystem.primaryColor,
      brightness: Brightness.dark,
      surface: const Color(0xFF141218),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightScheme,
      scaffoldBackgroundColor: Colors.white,
      textTheme: DesignSystem.textTheme.apply(
        bodyColor: lightScheme.onSurface,
        displayColor: lightScheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
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
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.06),
      ),
      dividerColor: Colors.black12,
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: lightScheme.primary,
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkScheme,
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      textTheme: DesignSystem.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.symmetric(vertical: 8),
        color: Color(0xFF1A1A1A),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF667EEA),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Color(0xFF667EEA),
        unselectedItemColor: Colors.grey,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        indicatorColor: Color(0xFF667EEA),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(color: Colors.white),
        ),
        iconTheme: MaterialStatePropertyAll(
          IconThemeData(color: Colors.white),
        ),
      ),
    );

    return ProviderScope(
      child: MaterialApp(
        title: 'Daily Tracker',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: const AppShell(),
      ),
    );
  }
}
