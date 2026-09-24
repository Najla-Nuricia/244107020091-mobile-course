import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/providers.dart';

final noteDetailProvider = FutureProvider.family<Note?, int>((ref, id) {
  return ref.watch(noteRepositoryProvider).fetchNoteById(id);
});

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({super.key, required this.noteId});

  final int noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteDetailProvider(noteId));
    return Scaffold(
      appBar: AppBar(title: const Text('Detail catatan')),
      body: note.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Gagal membaca catatan: $error')),
        data: (value) => value == null
            ? const Center(child: Text('Catatan tidak ditemukan'))
            : _NoteDetail(note: value),
      ),
    );
  }
}

class _NoteDetail extends StatelessWidget {
  const _NoteDetail({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        if (note.dirty)
          const Align(
            alignment: Alignment.centerLeft,
            child: Chip(
              label: Text('Belum tersinkron'),
              avatar: Icon(Icons.cloud_upload_outlined, size: 16),
            ),
          ),
        const SizedBox(height: 16),
        Text(note.body.isEmpty ? 'Tidak ada isi' : note.body),
        const SizedBox(height: 24),
        Text(
          'Diperbarui ${note.updatedAt.toLocal()}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
