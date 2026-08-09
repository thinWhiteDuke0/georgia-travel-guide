import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/widgets/async_view.dart';
import '../cities/presentation/cities_providers.dart';
import '../places/presentation/places_providers.dart';

/// Shows a city and its attractions on an OpenStreetMap tile layer
/// (no API key required).
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key, required this.cityId});
  final int cityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cityAsync = ref.watch(cityProvider(cityId));
    final attractionsAsync = ref.watch(attractionsProvider(cityId));

    return Scaffold(
      appBar: AppBar(title: const Text('რუკა')),
      body: AsyncView(
        value: cityAsync,
        onRetry: () => ref.invalidate(cityProvider(cityId)),
        data: (city) {
          final center = LatLng(
            city.latitude != 0 ? city.latitude : 41.7151,
            city.longitude != 0 ? city.longitude : 44.8271,
          );
          final markers = <Marker>[
            Marker(
              point: center,
              width: 44,
              height: 44,
              child: const Icon(Icons.location_city, color: Color(0xFF2E5496), size: 36),
            ),
            ...?attractionsAsync.valueOrNull
                ?.where((a) => a.latitude != 0 || a.longitude != 0)
                .map((a) => Marker(
                      point: LatLng(a.latitude, a.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.place, color: Colors.redAccent, size: 32),
                    )),
          ];

          return FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 12),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.georgia_travel_guide',
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
