class RouteModel {
  RouteModel({
    required this.id,
    required this.cityId,
    required this.title,
    required this.description,
    required this.durationHours,
    required this.difficulty,
  });

  final int id;
  final int cityId;
  final String title;
  final String description;
  final double durationHours;
  final String difficulty;

  factory RouteModel.fromJson(Map<String, dynamic> j) => RouteModel(
        id: (j['id'] as num).toInt(),
        cityId: (j['city_id'] as num?)?.toInt() ?? 0,
        title: (j['title'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        durationHours: (j['duration_hours'] as num?)?.toDouble() ?? 0,
        difficulty: (j['difficulty'] ?? '') as String,
      );
}
