import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/push_service.dart';

final apiClientProvider = Provider((ref) {
  final client = buildApiClient(
    ref.watch(sessionStoreProvider),
    ref.watch(authRepositoryProvider),
    onSessionExpired: () => ref.read(authStateProvider.notifier).logout(),
  );
  ref.onDispose(() => client.close(force: true));
  return client;
});

final pushServiceProvider = Provider<PushService>((ref) {
  final service = PushService(dio: ref.watch(apiClientProvider));
  ref.onDispose(service.dispose);
  return service;
});

final deviceTokenProvider = AsyncNotifierProvider<DeviceTokenNotifier, String?>(
  DeviceTokenNotifier.new,
);

class DeviceTokenNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final pushService = ref.watch(pushServiceProvider);
    final subscription = pushService.onTokenRefresh.listen(
      (token) => state = AsyncData(token),
      onError: (Object error, StackTrace stackTrace) {
        state = AsyncError(error, stackTrace);
      },
    );
    ref.onDispose(() => unawaited(subscription.cancel()));
    return pushService.getToken();
  }
}
