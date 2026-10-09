import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/providers/auth_providers.dart';
import 'network/api_client.dart';

final apiClientProvider = Provider((ref) {
  final client = buildApiClient(
    ref.watch(sessionStoreProvider),
    ref.watch(authRepositoryProvider),
    onSessionExpired: () => ref.read(authStateProvider.notifier).logout(),
  );
  ref.onDispose(() => client.close(force: true));
  return client;
});
