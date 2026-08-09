import 'package:flutter/material.dart';

/// Design tokens for the app.
///
/// Palette is built around the Black Sea: a turquoise primary, a deep
/// sea-ink for text, and a barely-cool off-white ground so white cards
/// still read as white.
class AppColors {
  static const ink = Color(0xFF0B2B33); // headings
  static const inkSoft = Color(0xFF3D5A61); // body copy
  static const muted = Color(0xFF7A949B); // captions, meta

  static const teal = Color(0xFF0E8C9E); // primary
  static const tealDeep = Color(0xFF075E6B); // pressed / dark accents
  static const tealWash = Color(0xFFE3F1F3); // tinted fills

  static const ground = Color(0xFFF4F8F9); // page background
  static const surface = Color(0xFFFFFFFF); // cards
  static const line = Color(0xFFE2EBED); // hairlines

  static const rose = Color(0xFFE0475F); // saved / favourite only
}

/// Type scale. Personality here comes from spacing and weight rather than
/// a decorative face, because the UI is Georgian and must fall back to the
/// system Georgian face cleanly.
class AppType {
  static const display = TextStyle(
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: AppColors.ink,
  );

  static const title = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.ink,
  );

  static const cardTitle = TextStyle(
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.ink,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.65,
    color: AppColors.inkSoft,
  );

  static const bodySm = TextStyle(
    fontSize: 13.5,
    height: 1.5,
    color: AppColors.muted,
  );

  /// Small caps label. Used for regions, section markers, categories.
  static const eyebrow = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    color: AppColors.muted,
  );

  /// The signature: real latitude/longitude, set like an instrument readout.
  static const coord = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.6,
    color: AppColors.muted,
  );
}

class Insets {
  static const page = 20.0;
  static const gap = 12.0;
}

/// Formats coordinates the way a map legend would.
String formatCoords(double lat, double lon) {
  if (lat == 0 && lon == 0) return '';
  final ns = lat >= 0 ? 'N' : 'S';
  final ew = lon >= 0 ? 'E' : 'W';
  return '${lat.abs().toStringAsFixed(2)}°$ns  ${lon.abs().toStringAsFixed(2)}°$ew';
}
