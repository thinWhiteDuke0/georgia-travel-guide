import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/labels.dart';
import '../../../core/widgets/seeded_art.dart';
import '../../favorites/presentation/favorites_controller.dart';
import '../../places/presentation/places_providers.dart';
import '../../routes/presentation/routes_providers.dart';
import 'cities_providers.dart';

class CityDetailScreen extends ConsumerWidget {
  const CityDetailScreen({super.key, required this.cityId});
  final int cityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityAsync = ref.watch(cityProvider(cityId));
    ref.watch(favoritesControllerProvider);
    final favs = ref.read(favoritesControllerProvider.notifier);
    final isSaved = favs.isFavorite('city', cityId);

    return Scaffold(
      body: AsyncView(
        value: cityAsync,
        onRetry: () => ref.invalidate(cityProvider(cityId)),
        data: (city) => DefaultTabController(
          length: 4,
          child: NestedScrollView(
            headerSliverBuilder: (context, _) => [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppColors.ground,
                surfaceTintColor: Colors.transparent,
                leading: const _RoundIcon(icon: Icons.arrow_back_rounded),
                actions: [
                  _RoundIcon(
                    icon: Icons.map_outlined,
                    onTap: () => context.push('/cities/$cityId/map'),
                  ),
                  _RoundIcon(
                    icon: isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isSaved ? AppColors.rose : null,
                    onTap: () => favs.toggle('city', cityId),
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CoverImage(url: city.imageUrl, seed: city.id, label: city.name),
                      // Scrim so the overlaid type stays legible.
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black26, Colors.transparent, Colors.black54],
                            stops: [0, 0.45, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: Insets.page,
                        right: Insets.page,
                        bottom: 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (city.region.isNotEmpty)
                              Eyebrow(city.region, color: Colors.white.withOpacity(0.9)),
                            const SizedBox(height: 8),
                            Text(
                              city.name,
                              style: AppType.display.copyWith(color: Colors.white, fontSize: 34),
                            ),
                            const SizedBox(height: 10),
                            CoordTag(formatCoords(city.latitude, city.longitude), onLight: false),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                bottom: const _Tabs(),
              ),
              if (city.description.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(Insets.page, 20, Insets.page, 4),
                    child: Text(city.description, style: AppType.body),
                  ),
                ),
            ],
            body: TabBarView(
              children: [
                _AttractionsTab(cityId: cityId),
                _RestaurantsTab(cityId: cityId),
                _HotelsTab(cityId: cityId),
                _RoutesTab(cityId: cityId),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tabs extends StatelessWidget implements PreferredSizeWidget {
  const _Tabs();
  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ground,
      alignment: Alignment.centerLeft,
      child: TabBar(
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        padding: const EdgeInsets.symmetric(horizontal: Insets.page - 4),
        labelColor: AppColors.ink,
        unselectedLabelColor: AppColors.muted,
        labelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500),
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: AppColors.line,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.teal, width: 2.5),
          insets: EdgeInsets.symmetric(horizontal: 4),
        ),
        tabs: const [
          Tab(text: 'სანახავი'),
          Tab(text: 'სადილი'),
          Tab(text: 'ღამისთევა'),
          Tab(text: 'მარშრუტები'),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, this.onTap, this.color});
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.white.withOpacity(0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => Navigator.of(context).maybePop(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: color ?? AppColors.ink),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- tabs

class _AttractionsTab extends ConsumerWidget {
  const _AttractionsTab({required this.cityId});
  final int cityId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView(
      value: ref.watch(attractionsProvider(cityId)),
      onRetry: () => ref.invalidate(attractionsProvider(cityId)),
      data: (items) => _TabList(
        items: items,
        emptyTitle: 'სანახავი ჯერ არ დამატებულა',
        emptyMessage: 'ამ ქალაქის ღირსშესანიშნაობებს მალე დავამატებთ.',
        builder: (a) => _Row(
          icon: Icons.landscape_outlined,
          title: a.name,
          subtitle: a.description,
          eyebrow: a.category,
          trailing: formatCoords(a.latitude, a.longitude),
        ),
      ),
    );
  }
}

class _RestaurantsTab extends ConsumerWidget {
  const _RestaurantsTab({required this.cityId});
  final int cityId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView(
      value: ref.watch(restaurantsProvider(cityId)),
      onRetry: () => ref.invalidate(restaurantsProvider(cityId)),
      data: (items) => _TabList(
        items: items,
        emptyTitle: 'რესტორნები ჯერ არ დამატებულა',
        emptyMessage: 'კვების ობიექტების სია მალე გამოჩნდება.',
        builder: (r) => _Row(
          icon: Icons.local_dining_outlined,
          title: r.name,
          subtitle: r.address,
          eyebrow: r.cuisine,
          trailing: '₾' * r.priceLevel.clamp(1, 4),
        ),
      ),
    );
  }
}

class _HotelsTab extends ConsumerWidget {
  const _HotelsTab({required this.cityId});
  final int cityId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView(
      value: ref.watch(hotelsProvider(cityId)),
      onRetry: () => ref.invalidate(hotelsProvider(cityId)),
      data: (items) => _TabList(
        items: items,
        emptyTitle: 'სასტუმროები ჯერ არ დამატებულა',
        emptyMessage: 'განთავსების ვარიანტები მალე გამოჩნდება.',
        builder: (h) => _Row(
          icon: Icons.king_bed_outlined,
          title: h.name,
          subtitle: h.address,
          trailing: '★' * h.stars.clamp(0, 5),
        ),
      ),
    );
  }
}

class _RoutesTab extends ConsumerWidget {
  const _RoutesTab({required this.cityId});
  final int cityId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncView(
      value: ref.watch(cityRoutesProvider(cityId)),
      onRetry: () => ref.invalidate(cityRoutesProvider(cityId)),
      data: (items) => _TabList(
        items: items,
        emptyTitle: 'მარშრუტები ჯერ არ დამატებულა',
        emptyMessage: 'რეკომენდებული მარშრუტები მალე გამოჩნდება.',
        builder: (r) => _Row(
          icon: Icons.timeline_rounded,
          title: r.title,
          subtitle: r.description,
          eyebrow: r.difficulty,
          trailing: '${r.durationHours.toStringAsFixed(0)} სთ',
          onTap: () => context.push('/routes/${r.id}'),
        ),
      ),
    );
  }
}

class _TabList<T> extends StatelessWidget {
  const _TabList({
    required this.items,
    required this.builder,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<T> items;
  final Widget Function(T) builder;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 40),
        StateMessage(icon: Icons.explore_off_outlined, title: emptyTitle, message: emptyMessage),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(Insets.page, 12, Insets.page, 24),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Divider(),
      ),
      itemBuilder: (_, i) => builder(items[i]),
    );
  }
}

/// One content row. Kept flat (no cards) so the list stays calm and the
/// hairline rules do the separating.
class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.title,
    this.subtitle = '',
    this.eyebrow = '',
    this.trailing = '',
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String eyebrow;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: AppColors.tealWash,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 19, color: AppColors.tealDeep),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eyebrow.isNotEmpty) ...[
                    Eyebrow(eyebrow),
                    const SizedBox(height: 4),
                  ],
                  Text(title, style: AppType.cardTitle.copyWith(fontSize: 15.5)),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(subtitle, style: AppType.bodySm, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            if (trailing.isNotEmpty) ...[
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(trailing, style: AppType.coord.copyWith(color: AppColors.inkSoft)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
