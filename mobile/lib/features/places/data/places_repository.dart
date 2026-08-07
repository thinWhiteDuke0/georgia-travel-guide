import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'place_models.dart';

final placesRepositoryProvider =
    Provider<PlacesRepository>((ref) => PlacesRepository(ref.watch(dioProvider)));

class PlacesRepository {
  PlacesRepository(this._dio);
  final Dio _dio;

  Future<List<Attraction>> attractions(int cityId) => _get(
      '/api/cities/$cityId/attractions', 'attractions', (m) => Attraction.fromJson(m));
  Future<List<Restaurant>> restaurants(int cityId) => _get(
      '/api/cities/$cityId/restaurants', 'restaurants', (m) => Restaurant.fromJson(m));
  Future<List<Hotel>> hotels(int cityId) =>
      _get('/api/cities/$cityId/hotels', 'hotels', (m) => Hotel.fromJson(m));

  Future<List<T>> _get<T>(String path, String key, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final r = await _dio.get(path);
      final list = ((r.data as Map<String, dynamic>)[key] as List?) ?? const [];
      return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
