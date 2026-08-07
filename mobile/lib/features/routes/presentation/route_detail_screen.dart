import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/labels.dart';
import 'routes_providers.dart';

class RouteDetailScreen extends ConsumerWidget {
  const RouteDetailScreen({super.key, required this.routeId});
  final int routeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(routeProvider(routeId));
    return Scaffold(
      appBar: AppBar(title: const Text('მარშრუტი')),
      body: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(routeProvider(routeId)),
        data: (r) => ListView(
          padding: const EdgeInsets.fromLTRB(Insets.page, 8, Insets.page, 32),
          children: [
            const Eyebrow('ტურისტული მარშრუტი'),
            const SizedBox(height: 10),
            Text(r.title, style: AppType.display),
            const SizedBox(height: 20),
            Row(
              children: [
                _Stat(
                  label: 'ხანგრძლივობა',
                  value: '${r.durationHours.toStringAsFixed(0)} სთ',
                  icon: Icons.schedule_rounded,
                ),
                const SizedBox(width: 12),
                if (r.difficulty.isNotEmpty)
                  _Stat(label: 'სირთულე', value: r.difficulty, icon: Icons.terrain_rounded),
              ],
            ),
            const SizedBox(height: 28),
            const SectionHeader('აღწერა'),
            Text(r.description, style: AppType.body),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.tealDeep),
            const SizedBox(height: 10),
            Eyebrow(label),
            const SizedBox(height: 4),
            Text(value, style: AppType.cardTitle.copyWith(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
