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
      appBar: AppBar(
        title: const Text('Detail catatan'),
        actions: [
          if (note.value != null)
            IconButton(
              tooltip: 'Edit catatan',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _editNote(context, ref, note.value!),
            ),
        ],
      ),
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

  Future<void> _editNote(BuildContext context, WidgetRef ref, Note note) async {
    final title = TextEditingController(text: note.title);
    final body = TextEditingController(text: note.body);
    final formKey = GlobalKey<FormState>();
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit catatan'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: title,
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
                  .updateNote(
                    id: note.id!,
                    title: title.text.trim(),
                    body: body.text.trim(),
                  );
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
      ref.invalidate(noteDetailProvider(note.id!));
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyNotesCountProvider);
    }
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
