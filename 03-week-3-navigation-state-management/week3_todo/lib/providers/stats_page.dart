import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'stats_provider.dart';
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar:AppBar(
        title: const Text('Stats'),
        ),
        body: statsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),

          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),

          data: (stats) => Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total tugas: ${stats['total']}'),
                Text('Selesai: ${stats['selesai']}'),
                Text('Belum selesai: ${stats['belum']}'),
              ],
            ),
          ),
        ),
      );
  }
}