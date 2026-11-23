import 'package:material_ui/material_ui.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.card,
    required this.cardAlt,
    required this.field,
    required this.border,
    required this.text,
    required this.bodyText,
    required this.muted,
    required this.primary,
    required this.tint,
    required this.tintDarker,
    required this.success,
    required this.warning,
    required this.info,
    required this.danger,
    required this.nude,
    required this.softPink,
    required this.lilac,
    required this.peach,
    required this.butter,
    required this.mint,
    required this.tile,
    required this.onPrimary,
    required this.shadow,
  });

  final Color background;
  final Color surface;
  final Color card;
  final Color cardAlt;
  final Color field;
  final Color border;
  final Color text;
  final Color bodyText;
  final Color muted;
  final Color primary;
  final Color tint;
  final Color tintDarker;
  final Color success;
  final Color warning;
  final Color info;
  final Color danger;
  final Color nude;
  final Color softPink;
  final Color lilac;
  final Color peach;
  final Color butter;
  final Color mint;
  final Color tile;
  final Color onPrimary;
  final Color shadow;

  static const light = AppColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFAFAFA),
    card: Color(0xFFFFFFFF),
    cardAlt: Color(0xFFFFF7FA),
    field: Color(0xFFF0F0F0),
    border: Color(0xFFF4EBFA),
    text: Color(0xFF3E0554),
    bodyText: Color(0xFF333333),
    muted: Color(0xFF7C7C7C),
    primary: Color(0xFFFF4576),
    tint: Color(0xFFFF7B83),
    tintDarker: Color(0xFFE8535C),
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9500),
    info: Color(0xFF007AFF),
    danger: Color(0xFFFF2F66),
    nude: Color(0xFFFEEFEC),
    softPink: Color(0xFFFFF0FB),
    lilac: Color(0xFFC9A7FF),
    peach: Color(0xFFFFB199),
    butter: Color(0xFFFFF3D6),
    mint: Color(0xFFB8E6CF),
    tile: Color(0xFFFFF0FB),
    onPrimary: Color(0xFFFFFFFF),
    shadow: Color(0x143E0554),
  );

  static const dark = AppColors(
    background: Color(0xFF0F0214),
    surface: Color(0xFF121212),
    card: Color(0xFF241629),
    cardAlt: Color(0xFF1F1F1F),
    field: Color(0xFF363636),
    border: Color(0xFF2F1C36),
    text: Color(0xFFFFFFFF),
    bodyText: Color(0xFFE8E2EA),
    muted: Color(0xFF9B93A0),
    primary: Color(0xFFFF4576),
    tint: Color(0xFFFF7B83),
    tintDarker: Color(0xFFE8535C),
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9F0A),
    info: Color(0xFF0A84FF),
    danger: Color(0xFFFF2F66),
    nude: Color(0xFF362420),
    softPink: Color(0xFF3E2436),
    lilac: Color(0xFF6B4D8F),
    peach: Color(0xFF7A4A3A),
    butter: Color(0xFF4A3F22),
    mint: Color(0xFF2A4A3A),
    tile: Color(0xFF3E2436),
    onPrimary: Color(0xFFFFFFFF),
    shadow: Color(0x66000000),
  );

  static const notePalette = <Color>[
    Color(0xFFFFFFFF),
    Color(0xFFF0C311),
    Color(0xFFFF9500),
    Color(0xFFFF7B83),
    Color(0xFFFF2F66),
    Color(0xFFFF6895),
    Color(0xFFD63FB8),
    Color(0xFFAF52DE),
    Color(0xFF5856D6),
    Color(0xFF68B4FF),
    Color(0xFF30B0C7),
    Color(0xFF00C7BE),
    Color(0xFF34C759),
    Color(0xFFA3C940),
    Color(0xFFA2845E),
  ];

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? card,
    Color? cardAlt,
    Color? field,
    Color? border,
    Color? text,
    Color? bodyText,
    Color? muted,
    Color? primary,
    Color? tint,
    Color? tintDarker,
    Color? success,
    Color? warning,
    Color? info,
    Color? danger,
    Color? nude,
    Color? softPink,
    Color? lilac,
    Color? peach,
    Color? butter,
    Color? mint,
    Color? tile,
    Color? onPrimary,
    Color? shadow,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      cardAlt: cardAlt ?? this.cardAlt,
      field: field ?? this.field,
      border: border ?? this.border,
      text: text ?? this.text,
      bodyText: bodyText ?? this.bodyText,
      muted: muted ?? this.muted,
      primary: primary ?? this.primary,
      tint: tint ?? this.tint,
      tintDarker: tintDarker ?? this.tintDarker,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      danger: danger ?? this.danger,
      nude: nude ?? this.nude,
      softPink: softPink ?? this.softPink,
      lilac: lilac ?? this.lilac,
      peach: peach ?? this.peach,
      butter: butter ?? this.butter,
      mint: mint ?? this.mint,
      tile: tile ?? this.tile,
      onPrimary: onPrimary ?? this.onPrimary,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardAlt: Color.lerp(cardAlt, other.cardAlt, t)!,
      field: Color.lerp(field, other.field, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      bodyText: Color.lerp(bodyText, other.bodyText, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      tintDarker: Color.lerp(tintDarker, other.tintDarker, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      nude: Color.lerp(nude, other.nude, t)!,
      softPink: Color.lerp(softPink, other.softPink, t)!,
      lilac: Color.lerp(lilac, other.lilac, t)!,
      peach: Color.lerp(peach, other.peach, t)!,
      butter: Color.lerp(butter, other.butter, t)!,
      mint: Color.lerp(mint, other.mint, t)!,
      tile: Color.lerp(tile, other.tile, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
  TextTheme get texts => Theme.of(this).textTheme;
}
