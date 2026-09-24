import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'data/local/database_factory.dart';
import 'data/providers.dart';
import 'pages/note_detail_page.dart';
import 'widgets/note_tile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabaseFactory();
  runApp(const ProviderScope(child: OfflineNotesApp()));
}

class OfflineNotesApp extends StatelessWidget {
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const NotesPage(),
          routes: [
            GoRoute(
              path: 'note/:id',
              builder: (context, state) {
                final id = int.tryParse(state.pathParameters['id'] ?? '');
                if (id == null) return const NoteNotFoundPage();
                return NoteDetailPage(noteId: id);
              },
            ),
          ],
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Offline Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final dirtyCount = ref.watch(dirtyNotesCountProvider).value ?? 0;
    final posts = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Offline Notes')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notesProvider);
          ref.invalidate(dirtyNotesCountProvider);
          ref.invalidate(postsProvider);
          await ref.read(postsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            _SyncStatus(
              dirtyCount: dirtyCount,
              onSync: () async {
                final synced = await syncNotesAndRefresh(ref);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$synced catatan disinkronkan.')),
                  );
                }
              },
            ),
            const SizedBox(height: 20),
            Text('Catatan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            notes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Gagal membaca catatan: $error'),
              data: (items) => items.isEmpty
                  ? const Text('Belum ada catatan.')
                  : Column(
                      children: items
                          .map(
                            (note) => Card(
                              child: NoteTile(
                                note: note,
                                onTap: () => context.push('/note/${note.id}'),
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
            const SizedBox(height: 28),
            Text('Cache posts', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            posts.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Gagal membaca cache posts: $error'),
              data: (items) =>
                  Text('${items.length} posts tersimpan di SQLite.'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncStatus extends StatelessWidget {
  const _SyncStatus({required this.dirtyCount, required this.onSync});

  final int dirtyCount;
  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          dirtyCount == 0
              ? Icons.cloud_done_outlined
              : Icons.cloud_upload_outlined,
        ),
        title: Text(
          dirtyCount == 0
              ? 'Semua catatan sudah tersinkron.'
              : '$dirtyCount catatan belum tersinkron.',
        ),
        trailing: dirtyCount == 0
            ? null
            : TextButton(onPressed: onSync, child: const Text('Sync')),
      ),
    );
  }
}

class NoteNotFoundPage extends StatelessWidget {
  const NoteNotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('ID catatan tidak valid.')));
  }
}
