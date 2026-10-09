import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/token_store.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/failures/auth_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/session_store.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(),
);
final sessionStoreProvider = Provider<SessionStore>((ref) => TokenStore());

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
    final token = await ref.watch(sessionStoreProvider).readAccess();
    return token != null && token.isNotEmpty;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      final session = await ref
          .read(authRepositoryProvider)
          .login(email: email, password: password);
      await ref
          .read(sessionStoreProvider)
          .save(access: session.access, refresh: session.refresh);
      state = const AsyncData(true);
    } on AuthFailure catch (error, stackTrace) {
      state = AsyncError<bool>(error.message, stackTrace);
    } catch (_, stackTrace) {
      state = AsyncError<bool>('Tidak dapat masuk. Coba lagi.', stackTrace);
    }
  }

  Future<void> logout() async {
    await ref.read(sessionStoreProvider).clear();
    state = const AsyncData(false);
  }
}
