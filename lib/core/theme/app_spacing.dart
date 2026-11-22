import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';

abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;
}

abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
}

abstract final class AppDurations {
  static const fast = Duration(milliseconds: 160);
  static const normal = Duration(milliseconds: 240);
  static const slow = Duration(milliseconds: 380);
}

abstract final class AppGradients {
  static const brand = LinearGradient(
    colors: [Color(0xFFFF4576), Color(0xFFFF7B83), Color(0xFFFFB199)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunrise = LinearGradient(
    colors: [Color(0xFFFF7B83), Color(0xFFFFB199)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const lilac = LinearGradient(
    colors: [Color(0xFF9B51E0), Color(0xFFFF6895)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const ocean = LinearGradient(
    colors: [Color(0xFF68B4FF), Color(0xFF30B0C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const meadow = LinearGradient(
    colors: [Color(0xFF34C759), Color(0xFFA3C940)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const sunset = LinearGradient(
    colors: [Color(0xFFFF9500), Color(0xFFFF2F66)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient soft(AppColors colors) => LinearGradient(
        colors: [colors.softPink, colors.nude],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient night(AppColors colors) => LinearGradient(
        colors: [colors.card, colors.background],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const avatarPalettes = <List<Color>>[
    [Color(0xFFFF7B83), Color(0xFFFF4576)],
    [Color(0xFF9B51E0), Color(0xFFD63FB8)],
    [Color(0xFF68B4FF), Color(0xFF5856D6)],
    [Color(0xFF30B0C7), Color(0xFF34C759)],
    [Color(0xFFFF9500), Color(0xFFFF7B83)],
    [Color(0xFFA3C940), Color(0xFF34C759)],
  ];
}

abstract final class AppShadows {
  static List<BoxShadow> soft(Color shadow) => [
        BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 10)),
      ];

  static List<BoxShadow> lifted(Color shadow) => [
        BoxShadow(color: shadow, blurRadius: 40, offset: const Offset(0, 18)),
      ];
}
