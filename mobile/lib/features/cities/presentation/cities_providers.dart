import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/city_model.dart';
import '../data/city_repository.dart';

/// Search + filter parameters for the cities list (value equality so the
/// FutureProvider.family re-fetches only when they actually change).
class CitiesQuery {
  const CitiesQuery({this.search = '', this.region = ''});
  final String search;
  final String region;

  CitiesQuery copyWith({String? search, String? region}) =>
      CitiesQuery(search: search ?? this.search, region: region ?? this.region);

  @override
  bool operator ==(Object other) =>
      other is CitiesQuery && other.search == search && other.region == region;
  @override
  int get hashCode => Object.hash(search, region);
}

final citiesProvider = FutureProvider.family<List<City>, CitiesQuery>((ref, q) {
  return ref.watch(cityRepositoryProvider).list(search: q.search, region: q.region);
});

final cityProvider = FutureProvider.family<City, int>((ref, id) {
  return ref.watch(cityRepositoryProvider).byId(id);
});
