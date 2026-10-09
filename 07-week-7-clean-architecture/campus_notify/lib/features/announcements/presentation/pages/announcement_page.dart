import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/failures/announcement_failure.dart';
import '../providers/announcements_providers.dart';

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcement = ref.watch(announcementProvider(id));
    return Scaffold(
      body: Center(
        child: announcement.when(
          loading: () => const CircularProgressIndicator(),
          data: (value) => Text('Announcement ID: ${value.id}'),
          error: (error, stackTrace) => Text(
            error is AnnouncementNotFoundFailure
                ? error.message
                : 'Pengumuman gagal dimuat.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
