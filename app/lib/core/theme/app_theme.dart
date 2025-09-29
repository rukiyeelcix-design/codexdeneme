import 'package:flutter/material.dart';

class AppPalette {
  const AppPalette({
    required this.name,
    required this.light,
    required this.dark,
  });

  final String name;
  final ThemeData light;
  final ThemeData dark;
}

class ThemeCatalog {
  static final palettes = <AppPalette>[
    _buildPalette(
      name: 'NeoMint',
      primary: const Color(0xFF2BD9A9),
      surface: const Color(0xFFF5FFFB),
      background: const Color(0xFFEAF7F4),
      darkPrimary: const Color(0xFF0AAE8A),
    ),
    _buildPalette(
      name: 'DeepOcean',
      primary: const Color(0xFF2E86DE),
      surface: const Color(0xFFF2F6FA),
      background: const Color(0xFFE8EEF6),
      darkPrimary: const Color(0xFF1B4F72),
    ),
    _buildPalette(
      name: 'SunsetCoral',
      primary: const Color(0xFFFF6F61),
      surface: const Color(0xFFFFF5F3),
      background: const Color(0xFFFBE9E7),
      darkPrimary: const Color(0xFFC6423A),
    ),
    _buildPalette(
      name: 'CharcoalGold',
      primary: const Color(0xFFD4AF37),
      surface: const Color(0xFFFAFAFA),
      background: const Color(0xFFEFE9D1),
      darkPrimary: const Color(0xFF816A00),
    ),
    _buildPalette(
      name: 'IvoryForest',
      primary: const Color(0xFF2F855A),
      surface: const Color(0xFFF7FAFC),
      background: const Color(0xFFE6FFFA),
      darkPrimary: const Color(0xFF276749),
    ),
  ];

  static AppPalette _buildPalette({
    required String name,
    required Color primary,
    required Color surface,
    required Color background,
    required Color darkPrimary,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      surface: surface,
      background: background,
    );
    final darkScheme = ColorScheme.fromSeed(
      seedColor: darkPrimary,
      brightness: Brightness.dark,
    );
    return AppPalette(
      name: name,
      light: ThemeData(
        colorScheme: colorScheme,
        useMaterial3: true,
        textTheme: Typography.englishLike2021.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
      ),
      dark: ThemeData(
        colorScheme: darkScheme,
        useMaterial3: true,
      ),
    );
  }
}
