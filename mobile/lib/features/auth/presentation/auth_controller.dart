import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

final authControllerProvider =
    NotifierProvider<AuthController, AuthStatus>(AuthController.new);

class AuthController extends Notifier<AuthStatus> {
  @override
  AuthStatus build() {
    _restore();
    return AuthStatus.unknown;
  }

  Future<void> _restore() async {
    final token = await ref.read(tokenStorageProvider).accessToken();
    state = token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  Future<void> login(String email, String password) async {
    final tokens = await ref.read(authRepositoryProvider).login(email, password);
    await ref.read(tokenStorageProvider).save(tokens);
    state = AuthStatus.authenticated;
  }

  Future<void> register(String email, String password, String fullName) async {
    final tokens = await ref.read(authRepositoryProvider).register(email, password, fullName);
    await ref.read(tokenStorageProvider).save(tokens);
    state = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    await ref.read(tokenStorageProvider).clear();
    state = AuthStatus.unauthenticated;
  }

  /// Called by the network layer when refresh fails.
  void forceLogout() => state = AuthStatus.unauthenticated;
}
