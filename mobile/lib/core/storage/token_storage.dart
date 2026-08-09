import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_models.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

/// Persists JWT tokens.
///
/// On Android and iOS this uses the platform secure storage (Keystore /
/// Keychain). On web it falls back to SharedPreferences, because
/// flutter_secure_storage needs the Web Crypto API (`crypto.subtle`), which
/// browsers only expose in a secure context and Safari restricts further.
/// Web is a development/preview target here, so the trade-off is acceptable;
/// the shipped mobile app always uses secure storage.
class TokenStorage {
  static const _access = 'access_token';
  static const _refresh = 'refresh_token';

  final _secure = const FlutterSecureStorage();

  Future<String?> accessToken() => _read(_access);
  Future<String?> refreshToken() => _read(_refresh);

  Future<String?> _read(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }
    return _secure.read(key: key);
  }

  Future<void> save(AuthTokens t) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_access, t.accessToken);
      await prefs.setString(_refresh, t.refreshToken);
      return;
    }
    await _secure.write(key: _access, value: t.accessToken);
    await _secure.write(key: _refresh, value: t.refreshToken);
  }

  Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_access);
      await prefs.remove(_refresh);
      return;
    }
    await _secure.delete(key: _access);
    await _secure.delete(key: _refresh);
  }
}
