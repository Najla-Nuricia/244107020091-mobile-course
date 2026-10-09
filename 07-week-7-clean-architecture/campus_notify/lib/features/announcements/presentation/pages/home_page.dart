import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notification_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceToken = ref.watch(deviceTokenProvider);
    final tokenText = deviceToken.when(
      data: (token) => token == null
          ? 'Memuat token...'
          : token.length > 12
          ? token.substring(0, 12)
          : 'Tersedia',
      loading: () => 'Memuat token...',
      error: (error, stackTrace) => 'Token tidak tersedia',
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home'),
            const SizedBox(height: 8),
            Text('Token FCM: $tokenText'),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => context.go(AppRoutes.announcement('3')),
              icon: const Icon(Icons.campaign_outlined),
              label: const Text('Pengumuman terbaru'),
            ),
            TextButton.icon(
              onPressed: () => ref.read(authStateProvider.notifier).logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Keluar'),
            ),
          ],
        ),
      ),
    );
  }
}
