import 'package:flutter/material.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/labels.dart';
import '../../../../core/widgets/seeded_art.dart';
import '../../data/city_model.dart';

/// Editorial card: image on top, a quiet text block beneath, and the city's
/// real coordinates as a footer readout.
class CityCard extends StatelessWidget {
  const CityCard({
    super.key,
    required this.city,
    required this.onTap,
    this.isSaved = false,
    this.onToggleSave,
  });

  final City city;
  final VoidCallback onTap;
  final bool isSaved;
  final VoidCallback? onToggleSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.page, 0, Insets.page, 16),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 5 / 3,
                    child: CoverImage(url: city.imageUrl, seed: city.id, label: city.name),
                  ),
                  if (onToggleSave != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _SaveButton(isSaved: isSaved, onTap: onToggleSave!),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (city.region.isNotEmpty) Eyebrow(city.region),
                    if (city.region.isNotEmpty) const SizedBox(height: 6),
                    Text(city.name, style: AppType.cardTitle),
                    if (city.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        city.description,
                        style: AppType.bodySm,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    CoordTag(formatCoords(city.latitude, city.longitude)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaved, required this.onTap});
  final bool isSaved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
            child: Icon(
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              key: ValueKey(isSaved),
              size: 19,
              color: isSaved ? AppColors.rose : AppColors.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}
