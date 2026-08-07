import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../favorites/presentation/favorites_controller.dart';
import 'cities_providers.dart';
import 'widgets/city_card.dart';

const _regions = ['ყველა', 'ქართლი', 'აჭარა', 'იმერეთი', 'მცხეთა', 'კახეთი', 'სამეგრელო'];

class CitiesScreen extends ConsumerStatefulWidget {
  const CitiesScreen({super.key});
  @override
  ConsumerState<CitiesScreen> createState() => _CitiesScreenState();
}

class _CitiesScreenState extends ConsumerState<CitiesScreen> {
  CitiesQuery _query = const CitiesQuery();
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final citiesAsync = ref.watch(citiesProvider(_query));
    ref.watch(favoritesControllerProvider);
    final favs = ref.read(favoritesControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Masthead
            Padding(
              padding: const EdgeInsets.fromLTRB(Insets.page, 16, Insets.page, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('საით მიემგზავრებით?', style: AppType.display),
                  const SizedBox(height: 6),
                  Text('აღმოაჩინეთ საქართველოს ქალაქები', style: AppType.bodySm),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SearchField(
              controller: _searchCtrl,
              onSubmit: (v) => setState(() => _query = _query.copyWith(search: v.trim())),
              onClear: () {
                _searchCtrl.clear();
                setState(() => _query = _query.copyWith(search: ''));
              },
            ),
            const SizedBox(height: 14),
            _RegionRail(
              selected: _query.region,
              onSelect: (r) => setState(() => _query = _query.copyWith(region: r)),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.teal,
                onRefresh: () async => ref.refresh(citiesProvider(_query).future),
                child: AsyncView(
                  value: citiesAsync,
                  onRetry: () => ref.invalidate(citiesProvider(_query)),
                  data: (cities) {
                    if (cities.isEmpty) {
                      return ListView(
                        children: [
                          const SizedBox(height: 60),
                          StateMessage(
                            icon: Icons.travel_explore_rounded,
                            title: 'ვერაფერი მოიძებნა',
                            message: _query.search.isNotEmpty
                                ? 'სცადეთ სხვა სახელი ან აირჩიეთ სხვა რეგიონი.'
                                : 'ამ რეგიონში ჯერ არ დაგვიმატებია ქალაქები.',
                            actionLabel: 'ფილტრის მოხსნა',
                            onAction: () {
                              _searchCtrl.clear();
                              setState(() => _query = const CitiesQuery());
                            },
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 8),
                      itemCount: cities.length,
                      itemBuilder: (_, i) {
                        final c = cities[i];
                        return CityCard(
                          city: c,
                          isSaved: favs.isFavorite('city', c.id),
                          onToggleSave: () => favs.toggle('city', c.id),
                          onTap: () => context.push('/cities/${c.id}'),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onSubmit, required this.onClear});
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.page),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmit,
        decoration: InputDecoration(
          hintText: 'ქალაქის ძებნა',
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted, size: 21),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 19, color: AppColors.muted),
                  onPressed: onClear,
                ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

/// Horizontal region filter. Custom pills rather than ChoiceChip so the
/// selected state matches the rest of the palette exactly.
class _RegionRail extends StatelessWidget {
  const _RegionRail({required this.selected, required this.onSelect});
  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Insets.page),
        itemCount: _regions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final r = _regions[i];
          final isAll = r == 'ყველა';
          final active = (isAll && selected.isEmpty) || r == selected;
          return GestureDetector(
            onTap: () => onSelect(isAll ? '' : r),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.ink : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: active ? AppColors.ink : AppColors.line),
              ),
              child: Text(
                r,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : AppColors.inkSoft,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
