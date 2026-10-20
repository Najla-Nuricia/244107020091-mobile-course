import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/features/notes/data/models/note_model.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/data/providers.dart';

import 'fake_note_repository.dart';

void main() {
  test('fromMap aman terhadap field yang hilang', () {
    final note = NoteModel.fromMap({'title': 'Belanja'});
    expect(note.title, 'Belanja');
    expect(note.body, '');
    expect(note.dirty, isFalse);
  });

  test('flag dirty bertahan pada serialisasi', () {
    final note = NoteModel(
      title: 'a',
      updatedAt: DateTime(2026, 9, 18),
      dirty: true,
    );
    final restored = NoteModel.fromMap(note.toMap());
    expect(restored.dirty, isTrue);
  });

  test('search judul sukses menemukan catatan tanpa peka huruf besar', () {
    final notes = [
      Note(title: 'Belanja Bulanan', updatedAt: DateTime.now()),
      Note(title: 'Rapat Tim', updatedAt: DateTime.now()),
    ];
    expect(filterNotesByTitle(notes, 'BULANAN').map((note) => note.title), [
      'Belanja Bulanan',
    ]);
  });

  test('search judul gagal menghasilkan empty state untuk query tak cocok', () {
    final notes = [Note(title: 'Belanja', updatedAt: DateTime.now())];
    expect(filterNotesByTitle(notes, 'Kuliah'), isEmpty);
  });

  test('search judul kosong mengembalikan semua catatan', () {
    final notes = [Note(title: 'Belanja', updatedAt: DateTime.now())];
    expect(filterNotesByTitle(notes, '  '), same(notes));
  });

  test('provider sukses dengan repository palsu', () async {
    final container = ProviderContainer(
      overrides: [
        noteRepositoryProvider.overrideWithValue(
          FakeNoteRepository(
            items: [Note(title: 'Tes', updatedAt: DateTime.now())],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final notes = await container.read(notesProvider.future);
    expect(notes.length, 1);
    expect(notes.first.title, 'Tes');
  });

  test('provider error dengan repository palsu', () async {
    final repository = FakeNoteRepository(throwError: true);
    await expectLater(repository.fetchNotes(), throwsA(isA<Exception>()));
  });
}
