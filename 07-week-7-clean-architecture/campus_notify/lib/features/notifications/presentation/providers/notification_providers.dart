import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers.dart';
import '../../data/push_service.dart';

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
