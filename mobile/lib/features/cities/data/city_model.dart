class City {
  City({
    required this.id,
    required this.name,
    required this.region,
    required this.description,
    required this.imageUrl,
    required this.latitude,
    required this.longitude,
  });

  final int id;
  final String name;
  final String region;
  final String description;
  final String imageUrl;
  final double latitude;
  final double longitude;

  factory City.fromJson(Map<String, dynamic> j) => City(
        id: (j['id'] as num).toInt(),
        name: (j['name'] ?? '') as String,
        region: (j['region'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        imageUrl: (j['image_url'] ?? '') as String,
        latitude: (j['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (j['longitude'] as num?)?.toDouble() ?? 0,
      );
}
