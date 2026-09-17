import 'package:flutter/material.dart';

/// Kerdos color tokens.
///
/// The palette is built around the product's actual subject matter: a
/// financial trust network. `ledger` is the brand/interactive color;
/// the four `status*` colors are not decoration — they are used
/// consistently everywhere a risk state appears anywhere in the app.
class AppColors {
  AppColors._();

  static const Color ledger = Color(0xFF1B6B5A);
  static const Color ledgerDark = Color(0xFF0F4A3D);
  static const Color ledgerLight = Color(0xFFDCEAE5);

  static const Color statusHealthy = Color(0xFF1B6B5A);
  static const Color statusIsolated = Color(0xFFC97F2A);
  static const Color statusContagion = Color(0xFFB23A34);
  static const Color statusRegional = Color(0xFF6B5FA8);

  static const Color ink = Color(0xFF161B19);
  static const Color inkMuted = Color(0xFF4B5450);
  static const Color paper = Color(0xFFEFF2EF);
  static const Color paperRaised = Color(0xFFFFFFFF);
  static const Color hairline = Color(0xFFD8DDD9);

  // Dark surface — used by the entry gateway and the graph/simulation
  // canvas, where a dark backdrop keeps the network animation legible.
  static const Color surfaceDark = Color(0xFF0E1412);
  static const Color surfaceDarkRaised = Color(0xFF161F1C);

  /// Subtle, organic card elevation that gives light mode cards an alive, floating tactile quality.
  static List<BoxShadow> get cardElevation => [
    BoxShadow(
      color: const Color(0xFF0E1E16).withValues(alpha: 0.05),
      blurRadius: 14,
      offset: const Offset(0, 3),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF0E1E16).withValues(alpha: 0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  /// Slightly more pronounced elevation for active or hero cards.
  static List<BoxShadow> get cardElevationRaised => [
    BoxShadow(
      color: const Color(0xFF0E1E16).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 5),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF0E1E16).withValues(alpha: 0.03),
      blurRadius: 6,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
}