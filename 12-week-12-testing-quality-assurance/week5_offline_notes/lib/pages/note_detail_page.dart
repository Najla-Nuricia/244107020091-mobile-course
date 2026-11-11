import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/notes/domain/entities/note.dart';
import '../features/notes/presentation/providers/notes_providers.dart';

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
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => _NoteEditDialog(
        note: note,
        onSave: (titleController, bodyController) async {
          await ref
              .read(noteRepositoryProvider)
              .updateNote(
                id: note.id!,
                title: titleController.text.trim(),
                body: bodyController.text.trim(),
              );
        },
      ),
    );
    if (saved == true) {
      ref.invalidate(noteDetailProvider(note.id!));
      ref.invalidate(notesProvider);
      ref.invalidate(dirtyNotesCountProvider);
    }
  }
}

class _NoteEditDialog extends StatefulWidget {
  const _NoteEditDialog({required this.note, required this.onSave});

  final Note note;
  final Future<void> Function(
    TextEditingController title,
    TextEditingController body,
  )
  onSave;

  @override
  State<_NoteEditDialog> createState() => _NoteEditDialogState();
}

class _NoteEditDialogState extends State<_NoteEditDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: '');
  final _bodyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.onSave(_titleController, _bodyController);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit catatan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Judul wajib diisi'
                  : null,
            ),
            TextField(
              controller: _bodyController,
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
        FilledButton(onPressed: _save, child: const Text('Simpan')),
      ],
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
