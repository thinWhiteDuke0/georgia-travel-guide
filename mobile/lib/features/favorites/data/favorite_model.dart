class Favorite {
  Favorite({required this.id, required this.entityType, required this.entityId});
  final int id;
  final String entityType;
  final int entityId;

  factory Favorite.fromJson(Map<String, dynamic> j) => Favorite(
        id: (j['id'] as num).toInt(),
        entityType: (j['entity_type'] ?? '') as String,
        entityId: (j['entity_id'] as num).toInt(),
      );
}
