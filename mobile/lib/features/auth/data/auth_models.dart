class AuthTokens {
  AuthTokens({required this.accessToken, required this.refreshToken, required this.userId});

  final String accessToken;
  final String refreshToken;
  final int userId;

  factory AuthTokens.fromJson(Map<String, dynamic> j) => AuthTokens(
        accessToken: j['access_token'] as String,
        refreshToken: j['refresh_token'] as String,
        userId: (j['user_id'] as num).toInt(),
      );
}

class Profile {
  Profile({required this.id, required this.email, required this.fullName, required this.avatarUrl});

  final int id;
  final String email;
  final String fullName;
  final String avatarUrl;

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: (j['id'] as num).toInt(),
        email: (j['email'] ?? '') as String,
        fullName: (j['full_name'] ?? '') as String,
        avatarUrl: (j['avatar_url'] ?? '') as String,
      );
}
