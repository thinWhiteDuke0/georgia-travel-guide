import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/place_models.dart';
import '../data/places_repository.dart';

final attractionsProvider = FutureProvider.family<List<Attraction>, int>(
    (ref, cityId) => ref.watch(placesRepositoryProvider).attractions(cityId));

final restaurantsProvider = FutureProvider.family<List<Restaurant>, int>(
    (ref, cityId) => ref.watch(placesRepositoryProvider).restaurants(cityId));

final hotelsProvider = FutureProvider.family<List<Hotel>, int>(
    (ref, cityId) => ref.watch(placesRepositoryProvider).hotels(cityId));
