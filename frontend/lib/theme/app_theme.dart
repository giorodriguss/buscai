import 'package:flutter/material.dart';

class AppColors {
  static const verde = Color(0xFF1A3A2A);
  static const laranja = Color(0xFFE85C2A);
  static const preto = Color(0xFF0F0E0D);
  static const papel = Color(0xFFF7F4EF);
  static const cinza = Color(0xFF7A7570);
  static const borda = Color(0xFFDDD9D2);
  static const branco = Color(0xFFFFFFFF);
  static const wpp = Color(0xFF25D366);

  static const verdeClaro = Color(0xFF2A5C40);
  static const laranjaClaro = Color(0xFFFF7A45);
}

class AppTextStyles {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 56,
    fontWeight: FontWeight.w700,
    letterSpacing: -2,
    height: 0.95,
    color: AppColors.branco,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    color: AppColors.branco,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 16,
    fontWeight: FontWeight.w300,
    height: 1.7,
    color: AppColors.branco,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.cinza,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: 'Georgia',
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 3,
    color: AppColors.laranja,
  );
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: 'Georgia',
    );
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.papel,
      colorScheme: const ColorScheme.light(
        primary: AppColors.verde,
        secondary: AppColors.laranja,
        surface: AppColors.papel,
      ),
      fontFamily: 'Georgia',
      textTheme: base.textTheme.apply(fontFamily: 'Georgia'),
      primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Georgia'),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.laranja,
          textStyle: const TextStyle(fontFamily: 'Georgia', fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(fontFamily: 'Georgia'),
      ),
    );
  }
}
