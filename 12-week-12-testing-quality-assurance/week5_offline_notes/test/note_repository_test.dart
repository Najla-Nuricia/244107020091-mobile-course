import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/get_notes.dart';
import 'package:week5_offline_notes/features/notes/domain/usecases/add_note.dart';

import 'fake_note_repository.dart';

void main() {
  group('NoteRepository via FakeNoteRepository (sukses)', () {
    test('fetchNotes mengembalikan daftar catatan', () async {
      final repository = FakeNoteRepository(
        items: [
          Note(id: 1, title: 'Belanja', updatedAt: DateTime(2026, 9, 18)),
          Note(id: 2, title: 'Rapat', updatedAt: DateTime(2026, 9, 19)),
        ],
      );

      final notes = await repository.fetchNotes();

      expect(notes.length, 2);
      expect(notes.first.title, 'Belanja');
      expect(notes.first.dirty, isFalse);
    });

    test('fetchNoteById mengembalikan catatan yang cocok', () async {
      final repository = FakeNoteRepository(
        items: [Note(id: 7, title: 'Server', updatedAt: DateTime(2026, 9, 20))],
      );

      final note = await repository.fetchNoteById(7);

      expect(note?.title, 'Server');
    });

    test('fetchNoteById mengembalikan null saat id tidak ada', () async {
      final repository = FakeNoteRepository(
        items: [Note(id: 7, title: 'Server', updatedAt: DateTime(2026, 9, 20))],
      );

      final note = await repository.fetchNoteById(99);

      expect(note, isNull);
    });

    test('addNote menyimpan catatan baru dengan dirty flag aktif', () async {
      final repository = FakeNoteRepository();

      final saved = await repository.addNote(title: 'Cairan', body: 'Bensin');

      expect(saved.id, isNotNull);
      expect(saved.title, 'Cairan');
      expect(saved.body, 'Bensin');
      expect(saved.dirty, isTrue);

      final notes = await repository.fetchNotes();
      expect(notes.length, 1);
      expect(notes.first.title, 'Cairan');
    });

    test('updateNote memperbarui judul body serta menandai dirty', () async {
      final repository = FakeNoteRepository(
        items: [
          Note(
            id: 3,
            title: 'Lama',
            body: 'lama body',
            updatedAt: DateTime(2026, 9, 18),
          ),
        ],
      );

      await repository.updateNote(id: 3, title: 'Baru', body: 'baru body');

      final notes = await repository.fetchNotes();
      expect(notes.first.title, 'Baru');
      expect(notes.first.body, 'baru body');
      expect(notes.first.dirty, isTrue);
    });

    test('deleteNote menghapus catatan dari daftar', () async {
      final repository = FakeNoteRepository(
        items: [Note(id: 3, title: 'Lama', updatedAt: DateTime(2026, 9, 18))],
      );

      await repository.deleteNote(3);

      final notes = await repository.fetchNotes();
      expect(notes, isEmpty);
    });

    test('markAllSynced membersihkan flag dirty', () async {
      final repository = FakeNoteRepository(
        items: [
          Note(
            id: 1,
            title: 'A',
            updatedAt: DateTime(2026, 9, 18),
            dirty: true,
          ),
          Note(id: 2, title: 'B', updatedAt: DateTime(2026, 9, 19)),
        ],
      );

      await repository.markAllSynced();

      final notes = await repository.fetchNotes();
      expect(notes.every((note) => !note.dirty), isTrue);
      expect(await repository.countDirty(), 0);
    });

    test('countDirty hanya menghitung catatan yang belum tersinkron', () async {
      final repository = FakeNoteRepository(
        items: [
          Note(
            id: 1,
            title: 'A',
            updatedAt: DateTime(2026, 9, 18),
            dirty: true,
          ),
          Note(id: 2, title: 'B', updatedAt: DateTime(2026, 9, 19)),
        ],
      );

      expect(await repository.countDirty(), 1);
    });
  });

  group('NoteRepository via FakeNoteRepository (error)', () {
    test('fetchNotes melempar exception saat throwError', () async {
      final repository = FakeNoteRepository(throwError: true);

      await expectLater(repository.fetchNotes(), throwsException);
    });

    test('GetNotes usecase meneruskan exception fetch', () async {
      final repository = FakeNoteRepository(throwError: true);
      final getNotes = GetNotes(repository);

      await expectLater(getNotes(), throwsException);
    });

    test('AddNote usecase meneruskan exception tambah', () async {
      final repository = FakeNoteRepository(throwError: true);
      final addNote = AddNote(repository);

      await expectLater(addNote(title: 'X', body: 'Y'), throwsException);
    });
  });
}
