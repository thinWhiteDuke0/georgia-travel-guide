import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/favorite_model.dart';
import '../data/favorites_repository.dart';

/// Holds the user's favorites and supports optimistic add/remove.
final favoritesControllerProvider =
    AsyncNotifierProvider<FavoritesController, List<Favorite>>(FavoritesController.new);

class FavoritesController extends AsyncNotifier<List<Favorite>> {
  @override
  Future<List<Favorite>> build() => ref.watch(favoritesRepositoryProvider).list();

  bool isFavorite(String type, int id) {
    final list = state.valueOrNull ?? const [];
    return list.any((f) => f.entityType == type && f.entityId == id);
  }

  Future<void> toggle(String type, int id) async {
    final repo = ref.read(favoritesRepositoryProvider);
    if (isFavorite(type, id)) {
      await repo.remove(type, id);
    } else {
      await repo.add(type, id);
    }
    state = await AsyncValue.guard(() => repo.list());
  }
}
