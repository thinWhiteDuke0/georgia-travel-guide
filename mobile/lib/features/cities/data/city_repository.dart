import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'city_model.dart';

final cityRepositoryProvider =
    Provider<CityRepository>((ref) => CityRepository(ref.watch(dioProvider)));

class CityRepository {
  CityRepository(this._dio);
  final Dio _dio;

  Future<List<City>> list({int page = 1, String region = '', String search = ''}) async {
    try {
      final r = await _dio.get('/api/cities', queryParameters: {
        'page': page,
        'page_size': 30,
        if (region.isNotEmpty) 'region': region,
        if (search.isNotEmpty) 'search': search,
      });
      final data = r.data as Map<String, dynamic>;
      final list = (data['cities'] as List?) ?? const [];
      return list.map((e) => City.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<City> byId(int id) async {
    try {
      final r = await _dio.get('/api/cities/$id');
      return City.fromJson(r.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
