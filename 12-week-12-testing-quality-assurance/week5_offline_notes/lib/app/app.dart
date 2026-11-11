import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/local/database_factory.dart';
import '../features/notes/domain/entities/note.dart';
import '../features/notes/presentation/providers/notes_providers.dart';
import '../data/providers.dart';
import '../data/prefs.dart';
import '../pages/settings_page.dart';
import '../routes.dart';
import '../widgets/note_tile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDatabaseFactory();
  final prefs = PrefsRepository();
  await prefs.markOpenedNow();
  runApp(const ProviderScope(child: OfflineNotesApp()));
}

class OfflineNotesApp extends ConsumerWidget {
  const OfflineNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkMode = ref.watch(darkModeProvider);
    return MaterialApp.router(
      title: 'Offline Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: darkMode.value == true ? ThemeMode.dark : ThemeMode.light,
      routerConfig: buildRouter(home: const NotesPage()),
    );
  }
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);
    final searchQuery = ref.watch(notesSearchQueryProvider);
    final dirtyCount = ref.watch(dirtyNotesCountProvider).value ?? 0;
    final posts = ref.watch(postsProvider);
    final lastOpened = ref.watch(lastOpenedProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          IconButton(
            tooltip: 'AI chat',
            icon: const Icon(Icons.smart_toy_outlined),
            onPressed: () => context.push('/chat'),
          ),
          IconButton(
            tooltip: 'Toggle tema',
            icon: Icon(
              ref.watch(darkModeProvider).value == true
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: () => ref.read(darkModeProvider.notifier).toggle(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(notesProvider);
          ref.invalidate(dirtyNotesCountProvider);
          ref.invalidate(postsProvider);
          await ref.read(postsProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
          children: [
            if (lastOpened != null)
              Text(
                'Terakhir dibuka: ${DateTime.tryParse(lastOpened)?.toLocal() ?? lastOpened}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Cari judul catatan',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) =>
                  ref.read(notesSearchQueryProvider.notifier).setQuery(query),
            ),
            const SizedBox(height: 12),
            Text('Catatan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            notes.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Gagal membaca catatan: $error'),
              data: (items) {
                final filteredItems = filterNotesByTitle(items, searchQuery);
                return filteredItems.isEmpty
                    ? Text(
                        searchQuery.trim().isEmpty
                            ? 'Belum ada catatan.'
                            : 'Tidak ada catatan yang cocok.',
                      )
                    : Column(
                        children: filteredItems
                            .map(
                              (note) => Card(
                                child: NoteTile(
                                  note: note,
                                  onTap: () => context.push('/note/${note.id}'),
                                  onDelete: () =>
                                      _deleteNote(context, ref, note),
                                ),
                              ),
                            )
                            .toList(),
                      );
              },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Catatan'),
      ),
    );
  }

  Future<void> _deleteNote(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('Catatan "${note.title}" akan dihapus dari perangkat.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(noteRepositoryProvider).deleteNote(note.id!);
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyNotesCountProvider);
    }
  }

  Future<void> _showNoteEditor(BuildContext context, WidgetRef ref) async {
    final title = TextEditingController();
    final body = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Catatan baru'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: title,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Judul wajib diisi'
                    : null,
              ),
              TextField(
                controller: body,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Isi catatan'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref
                  .read(noteRepositoryProvider)
                  .addNote(title: title.text.trim(), body: body.text.trim());
              if (context.mounted) Navigator.pop(context, true);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    title.dispose();
    body.dispose();
    if (saved == true) {
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyNotesCountProvider);
    }
  }
}

class _SyncStatus extends StatelessWidget {
  const _SyncStatus({required this.dirtyCount, required this.onSync});
  final int dirtyCount;
  final Future<void> Function() onSync;

  @override
  Widget build(BuildContext context) => Card(
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

class NoteNotFoundPage extends StatelessWidget {
  const NoteNotFoundPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('ID catatan tidak valid.')));
}
