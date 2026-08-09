import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'route_model.dart';

final routesRepositoryProvider =
    Provider<RoutesRepository>((ref) => RoutesRepository(ref.watch(dioProvider)));

class RoutesRepository {
  RoutesRepository(this._dio);
  final Dio _dio;

  Future<List<RouteModel>> list({int? cityId}) async {
    try {
      final r = await _dio.get('/api/routes', queryParameters: {
        if (cityId != null) 'city_id': cityId,
      });
      final list = ((r.data as Map<String, dynamic>)['routes'] as List?) ?? const [];
      return list.map((e) => RouteModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ApiException.from(e);
    }
  }

  Future<RouteModel> byId(int id) async {
    try {
      final r = await _dio.get('/api/routes/$id');
      return RouteModel.fromJson(r.data as Map<String, dynamic>);
    } catch (e) {
      throw ApiException.from(e);
    }
  }
}
