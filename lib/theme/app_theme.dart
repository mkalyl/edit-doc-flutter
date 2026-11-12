import 'package:flutter/material.dart';

/// Define os temas claro e escuro da aplicação em Material 3.
abstract final class AppTheme {
  static const Color _corSemente = Color(0xFF3F51B5);

  static ThemeData get claro => _construirTema(Brightness.light);

  static ThemeData get escuro => _construirTema(Brightness.dark);

  static ThemeData _construirTema(Brightness brilho) {
    final ColorScheme esquema = ColorScheme.fromSeed(
      seedColor: _corSemente,
      brightness: brilho,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}
