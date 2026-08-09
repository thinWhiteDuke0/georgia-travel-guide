import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/auth_controller.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/cities/presentation/city_detail_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/map/map_screen.dart';
import '../../features/routes/presentation/route_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod auth state to a Listenable that GoRouter can refresh on.
  final refresh = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, __) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final status = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/login' || loc == '/register';

      if (status == AuthStatus.unknown) return null; // wait for restore
      if (status == AuthStatus.unauthenticated) return onAuthPage ? null : '/login';
      if (onAuthPage) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: '/cities/:id',
        builder: (_, s) => CityDetailScreen(cityId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/cities/:id/map',
        builder: (_, s) => MapScreen(cityId: int.parse(s.pathParameters['id']!)),
      ),
      GoRoute(
        path: '/routes/:id',
        builder: (_, s) => RouteDetailScreen(routeId: int.parse(s.pathParameters['id']!)),
      ),
    ],
  );
});
