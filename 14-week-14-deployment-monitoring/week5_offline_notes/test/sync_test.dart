import 'package:flutter_test/flutter_test.dart';
import 'package:week5_offline_notes/data/sync.dart';
import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';

import 'fake_note_repository.dart';

void main() {
  group('syncNotes', () {
    test(
      'sukses menandai semua catatan tersinkron lalu mengembalikan jumlah',
      () async {
        final repository = FakeNoteRepository(
          items: [
            Note(
              id: 1,
              title: 'Belanja',
              updatedAt: DateTime(2026, 9, 18),
              dirty: true,
            ),
            Note(id: 2, title: 'Rapat', updatedAt: DateTime(2026, 9, 19)),
          ],
        );

        final syncedCount = await syncNotes(repository);

        expect(syncedCount, 1);
        final notes = await repository.fetchNotes();
        expect(notes.every((note) => !note.dirty), isTrue);
      },
    );

    test('tanpa catatan dirty mengembalikan 0 tanpa menyinkron', () async {
      final repository = FakeNoteRepository(
        items: [Note(id: 1, title: 'Rapat', updatedAt: DateTime(2026, 9, 19))],
      );

      final syncedCount = await syncNotes(repository);

      expect(syncedCount, 0);
      final notes = await repository.fetchNotes();
      expect(notes.first.dirty, isFalse);
    });

    test('error mengembalikan exception saat proses sync', () async {
      final repository = FakeNoteRepository(throwError: true);

      await expectLater(syncNotes(repository), throwsException);
    });
  });
}
