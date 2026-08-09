import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../cities/data/city_repository.dart';
import '../../cities/presentation/widgets/city_card.dart';
import '../../home/home_screen.dart';
import 'favorites_controller.dart';

/// Resolves saved city ids into full city records so the saved list can show
/// the same rich cards as the browse list.
final savedCitiesProvider = FutureProvider((ref) async {
  final favs = await ref.watch(favoritesControllerProvider.future);
  final ids = favs.where((f) => f.entityType == 'city').map((f) => f.entityId).toList();
  final repo = ref.watch(cityRepositoryProvider);
  return Future.wait(ids.map(repo.byId));
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(savedCitiesProvider);
    final favs = ref.read(favoritesControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(Insets.page, 16, Insets.page, 18),
              child: Text('შენახული', style: AppType.display),
            ),
            Expanded(
              child: AsyncView(
                value: async,
                onRetry: () => ref.invalidate(savedCitiesProvider),
                data: (cities) {
                  if (cities.isEmpty) {
                    return StateMessage(
                      icon: Icons.favorite_border_rounded,
                      title: 'ჯერ არაფერი შეგინახავთ',
                      message: 'ქალაქის ბარათზე გულის ღილაკით შეინახავთ იმას, რაც მოგეწონათ.',
                      actionLabel: 'ქალაქების დათვალიერება',
                      onAction: () => ref.read(homeTabProvider.notifier).state = 0,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: cities.length,
                    itemBuilder: (_, i) => CityCard(
                      city: cities[i],
                      isSaved: true,
                      onToggleSave: () => favs.toggle('city', cities[i].id),
                      onTap: () => context.push('/cities/${cities[i].id}'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
