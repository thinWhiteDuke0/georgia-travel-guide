import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../cities/presentation/cities_screen.dart';
import '../favorites/presentation/favorites_screen.dart';
import '../profile/presentation/profile_screen.dart';

/// Which top-level tab is showing. Lifted out of the widget so screens can
/// send the user elsewhere (e.g. the empty saved list links to browsing).
final homeTabProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _pages = [CitiesScreen(), FavoritesScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(homeTabProvider);

    return Scaffold(
      body: IndexedStack(index: index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2EBED))),
        ),
        child: NavigationBar(
          selectedIndex: index,
          onDestinationSelected: (i) => ref.read(homeTabProvider.notifier).state = i,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'აღმოჩენა',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'შენახული',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'პროფილი',
            ),
          ],
        ),
      ),
    );
  }
}
