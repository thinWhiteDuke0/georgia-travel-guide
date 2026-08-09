import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'favorite_model.dart';

final favoritesRepositoryProvider =
    Provider<FavoritesRepository>((ref) => FavoritesRepository(ref.watch(dioProvider)));

class FavoritesRepository {
  FavoritesRepository(this._dio);
  final Dio _dio;

  Future<List<Favorite>> list() async {
    try {
      final r = await _dio.get('/api/favorites');
      final list = ((r.data as Map<String, dynamic>)['favorites'] as List?) ?? const [];
      return list.map((e) => Favorite.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<void> add(String entityType, int entityId) async {
    try {
      await _dio.post('/api/favorites', data: {'entity_type': entityType, 'entity_id': entityId});
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<void> remove(String entityType, int entityId) async {
    try {
      await _dio.delete('/api/favorites', data: {'entity_type': entityType, 'entity_id': entityId});
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
