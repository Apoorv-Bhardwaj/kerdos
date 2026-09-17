import 'package:flutter/material.dart';

/// Kerdos type system. Newsreader carries identity moments (wordmark,
/// entry headline); PlexSans is the UI workhorse; PlexMono is reserved
/// for figures a person needs to read exactly — loan amounts, PAR%,
/// timestep counters — not used for ordinary labels.
class AppTypography {
  AppTypography._();

  static const String display = 'Newsreader';
  static const String ui = 'PlexSans';
  static const String figures = 'PlexMono';

  static TextTheme textTheme(Color onSurface) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: display,
        fontSize: 44,
        fontWeight: FontWeight.w500,
        height: 1.12,
        letterSpacing: -0.4,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontFamily: display,
        fontSize: 28,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontFamily: ui,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontFamily: ui,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontFamily: ui,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontFamily: ui,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: onSurface,
      ),
      labelLarge: TextStyle(
        fontFamily: ui,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      labelSmall: TextStyle(
        fontFamily: ui,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: onSurface,
      ),
    );
  }

  /// Tabular-figure style for financial numbers — used deliberately, not
  /// applied to general labels.
  static TextStyle figureStyle({
    required double size,
    required Color color,
    FontWeight weight = FontWeight.w500,
  }) {
    return TextStyle(
      fontFamily: figures,
      fontSize: size,
      fontWeight: weight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}