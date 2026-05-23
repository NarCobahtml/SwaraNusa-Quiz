import 'package:flutter/material.dart';
import 'package:swaranusaquiz/app/utils/app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(AppColors.primary.toARGB32(), const {
        50: Color(0xFFE8EEE9),
        100: Color(0xFFC5D5C9),
        200: Color(0xFF9FBAA7),
        300: Color(0xFF799F84),
        400: Color(0xFF5C8A69),
        500: Color(0xFF3E5C4A),
        600: Color(0xFF385443),
        700: Color(0xFF304A3A),
        800: Color(0xFF284132),
        900: Color(0xFF1B3022),
      }),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'PlusJakarta',
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
