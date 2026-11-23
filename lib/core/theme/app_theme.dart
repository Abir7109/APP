import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors c) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.softPink,
      onPrimaryContainer: c.text,
      secondary: c.tint,
      onSecondary: c.onPrimary,
      secondaryContainer: c.nude,
      onSecondaryContainer: c.text,
      tertiary: c.tintDarker,
      onTertiary: c.onPrimary,
      error: c.danger,
      onError: c.onPrimary,
      surface: c.background,
      onSurface: c.text,
      surfaceContainerHighest: c.field,
      onSurfaceVariant: c.muted,
      outline: c.border,
      outlineVariant: c.border,
      shadow: c.shadow,
      scrim: const Color(0x99000000),
      inverseSurface: c.text,
      onInverseSurface: c.background,
      inversePrimary: c.tint,
    );

    final base = ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: scheme,
    );
    final textTheme = _textTheme(base.textTheme, c);

    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      cardColor: c.card,
      dividerColor: c.border,
      textTheme: textTheme,
      extensions: [c],
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.text,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: (brightness == Brightness.dark
                ? SystemUiOverlayStyle.light
                : SystemUiOverlayStyle.dark)
            .copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: c.background,
        ),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: c.text,
          fontWeight: FontWeight.w800,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: brightness == Brightness.light ? c.cardAlt : c.field,
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.muted),
        labelStyle: textTheme.bodyMedium?.copyWith(color: c.muted),
        floatingLabelStyle: textTheme.bodyMedium?.copyWith(color: c.primary),
        prefixIconColor: c.muted,
        suffixIconColor: c.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: _inputBorder(Colors.transparent),
        enabledBorder: _inputBorder(Colors.transparent),
        focusedBorder: _inputBorder(c.primary, width: 1.6),
        errorBorder: _inputBorder(c.danger),
        focusedErrorBorder: _inputBorder(c.danger, width: 1.6),
        errorStyle: textTheme.bodySmall?.copyWith(color: c.danger),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.field,
          disabledForegroundColor: c.muted,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.text,
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          side: BorderSide(color: c.border),
          shape: const StadiumBorder(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          shape: const StadiumBorder(),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.field,
        selectedColor: c.softPink,
        disabledColor: c.field,
        labelStyle: textTheme.labelMedium?.copyWith(color: c.text),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: c.muted),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),
      cardTheme: CardThemeData(
        color: c.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          side: BorderSide(color: c.border),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.softPink,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? c.primary : c.muted,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            color: selected ? c.primary : c.muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: c.background,
        showDragHandle: true,
        dragHandleColor: c.border,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.xl),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: c.text,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: c.background,
          fontWeight: FontWeight.w600,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.border,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.muted,
        textColor: c.text,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.field,
        circularTrackColor: c.field,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.onPrimary;
          return c.muted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return c.field;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.md),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(TextTheme base, AppColors c) {
    final display = base.headlineMedium?.copyWith(
      color: c.text,
      fontWeight: FontWeight.w800,
      fontSize: 30,
      height: 1.12,
      letterSpacing: -0.5,
    );
    final title = base.titleMedium?.copyWith(
      color: c.text,
      fontWeight: FontWeight.w700,
      fontSize: 17,
      height: 1.25,
    );
    final body = base.bodyMedium?.copyWith(
      color: c.bodyText,
      fontWeight: FontWeight.w400,
      fontSize: 14.5,
      height: 1.5,
    );
    final caption = base.bodySmall?.copyWith(
      color: c.muted,
      fontWeight: FontWeight.w500,
      fontSize: 12.5,
      height: 1.4,
    );
    final label = base.labelSmall?.copyWith(
      color: c.muted,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      height: 1.2,
      letterSpacing: 0.4,
    );

    return base.copyWith(
      displaySmall: display,
      headlineMedium: display,
      headlineSmall: display?.copyWith(
        fontSize: 20,
        height: 1.2,
        letterSpacing: -0.2,
      ),
      titleLarge: title?.copyWith(fontSize: 20, fontWeight: FontWeight.w800),
      titleMedium: title,
      titleSmall: title?.copyWith(fontSize: 15),
      bodyLarge: body?.copyWith(fontSize: 15.5),
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: label?.copyWith(fontSize: 14, color: c.text),
      labelMedium: label?.copyWith(fontSize: 13, color: c.text),
      labelSmall: label,
    );
  }
}
