import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api_errors.dart';
import '../data/auth_repository.dart';
import '../data/token_store.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);
final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore());

final authStateProvider = AsyncNotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class AuthRouterRefresh extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final authRouterRefreshProvider = Provider<AuthRouterRefresh>((ref) {
  final refresh = AuthRouterRefresh();
  ref.listen(authStateProvider, (previous, next) => refresh.refresh());
  ref.onDispose(refresh.dispose);
  return refresh;
});

class AuthNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    try {
      final token = await ref.watch(tokenStoreProvider).readAccess();
      return token != null && token.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(tokenStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      state = const AsyncData(true);
    } on DioException catch (error, stackTrace) {
      state = AsyncError<bool>(apiErrorMessage(error), stackTrace);
    } catch (_, stackTrace) {
      state = AsyncError<bool>('Tidak dapat masuk. Coba lagi.', stackTrace);
    }
  }

  Future<void> logout() async {
    await ref.read(tokenStoreProvider).clear();
    state = const AsyncData(false);
  }
}
