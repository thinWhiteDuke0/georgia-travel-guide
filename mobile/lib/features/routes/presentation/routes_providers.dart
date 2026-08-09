import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/route_model.dart';
import '../data/routes_repository.dart';

final cityRoutesProvider = FutureProvider.family<List<RouteModel>, int>(
    (ref, cityId) => ref.watch(routesRepositoryProvider).list(cityId: cityId));

final routeProvider = FutureProvider.family<RouteModel, int>(
    (ref, id) => ref.watch(routesRepositoryProvider).byId(id));
