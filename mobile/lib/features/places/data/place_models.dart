class Attraction {
  Attraction({required this.id, required this.name, required this.category, required this.description, required this.latitude, required this.longitude});
  final int id;
  final String name;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  factory Attraction.fromJson(Map<String, dynamic> j) => Attraction(
        id: (j['id'] as num).toInt(),
        name: (j['name'] ?? '') as String,
        category: (j['category'] ?? '') as String,
        description: (j['description'] ?? '') as String,
        latitude: (j['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (j['longitude'] as num?)?.toDouble() ?? 0,
      );
}

class Restaurant {
  Restaurant({required this.id, required this.name, required this.cuisine, required this.priceLevel, required this.address});
  final int id;
  final String name;
  final String cuisine;
  final int priceLevel;
  final String address;
  factory Restaurant.fromJson(Map<String, dynamic> j) => Restaurant(
        id: (j['id'] as num).toInt(),
        name: (j['name'] ?? '') as String,
        cuisine: (j['cuisine'] ?? '') as String,
        priceLevel: (j['price_level'] as num?)?.toInt() ?? 0,
        address: (j['address'] ?? '') as String,
      );
}

class Hotel {
  Hotel({required this.id, required this.name, required this.stars, required this.address});
  final int id;
  final String name;
  final int stars;
  final String address;
  factory Hotel.fromJson(Map<String, dynamic> j) => Hotel(
        id: (j['id'] as num).toInt(),
        name: (j['name'] ?? '') as String,
        stars: (j['stars'] as num?)?.toInt() ?? 0,
        address: (j['address'] ?? '') as String,
      );
}
