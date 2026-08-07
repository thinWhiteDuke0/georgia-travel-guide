import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

/// Small caps marker used above titles and section starts.
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppType.eyebrow.copyWith(color: color ?? AppColors.muted),
    );
  }
}

/// The signature element: a real lat/long readout, set like a map legend.
class CoordTag extends StatelessWidget {
  const CoordTag(this.text, {super.key, this.onLight = true});
  final String text;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    final color = onLight ? AppColors.muted : Colors.white.withOpacity(0.85);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 1, color: color.withOpacity(0.5)),
        const SizedBox(width: 6),
        Text(text, style: AppType.coord.copyWith(color: color)),
      ],
    );
  }
}

/// Section heading with a hairline that runs to the edge, echoing a horizon.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(title, style: AppType.eyebrow.copyWith(color: AppColors.ink)),
          const SizedBox(width: 12),
          const Expanded(child: Divider()),
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );
  }
}
