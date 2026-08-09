import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_tokens.dart';

/// Seeded artwork for records that have no photo.
///
/// The seed database ships without images, and a grey box for every city
/// would read as broken. Instead each id maps deterministically to one of a
/// small set of sea-and-mountain gradients, so the same city always looks
/// the same and the grid still reads as designed.
class SeededArt extends StatelessWidget {
  const SeededArt({super.key, required this.seed, this.label});

  final int seed;
  final String? label;

  static const _palettes = <List<Color>>[
    [Color(0xFF0E8C9E), Color(0xFF0B4F63)], // shallow sea
    [Color(0xFF12A0A8), Color(0xFF0A6A78)], // turquoise bay
    [Color(0xFF2E7D8C), Color(0xFF10333F)], // deep water
    [Color(0xFF3FA5A0), Color(0xFF15596B)], // coastal haze
    [Color(0xFF157C86), Color(0xFF07303C)], // night harbour
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _palettes[seed.abs() % _palettes.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CustomPaint(
        painter: _HorizonPainter(seed: seed),
        child: label == null
            ? const SizedBox.expand()
            : Center(
                child: Text(
                  label!.characters.first,
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.22),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Draws two soft horizon arcs so the gradient has some structure.
class _HorizonPainter extends CustomPainter {
  _HorizonPainter({required this.seed});
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final offset = (seed.abs() % 5) * 0.05;
    final paint = Paint()..color = Colors.white.withOpacity(0.07);

    final p1 = Path()
      ..moveTo(0, size.height * (0.62 + offset))
      ..quadraticBezierTo(
          size.width * 0.5, size.height * (0.44 + offset), size.width, size.height * (0.70 + offset))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p1, paint);

    final p2 = Path()
      ..moveTo(0, size.height * (0.80 + offset))
      ..quadraticBezierTo(
          size.width * 0.4, size.height * (0.66 + offset), size.width, size.height * (0.86 + offset))
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(p2, Paint()..color = Colors.white.withOpacity(0.06));
  }

  @override
  bool shouldRepaint(covariant _HorizonPainter old) => old.seed != seed;
}

/// Shows a remote photo when there is one, and falls back to [SeededArt].
class CoverImage extends StatelessWidget {
  const CoverImage({super.key, required this.url, required this.seed, this.label});

  final String url;
  final int seed;
  final String? label;

  /// The API returns paths like `/static/cities/batumi.jpg`; make them
  /// absolute against whichever gateway this build points at.
  String get _resolved {
    final u = url.trim();
    if (u.isEmpty) return '';
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    return '${AppConfig.apiBaseUrl}${u.startsWith('/') ? '' : '/'}$u';
  }

  @override
  Widget build(BuildContext context) {
    if (_resolved.isEmpty) return SeededArt(seed: seed, label: label);
    return CachedNetworkImage(
      imageUrl: _resolved,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 220),
      placeholder: (_, __) => const ColoredBox(color: AppColors.tealWash),
      errorWidget: (_, __, ___) => SeededArt(seed: seed, label: label),
    );
  }
}
