import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/main.dart';

import 'fake_note_repository.dart';

void main() {
  group('NotesPage (UI)', () {
    testWidgets('menampilkan tampilan awal saat belum ada catatan', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
          ],
          child: const OfflineNotesApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Offline Notes'), findsOneWidget);
      expect(find.text('Belum ada catatan.'), findsOneWidget);
      expect(find.text('Semua catatan sudah tersinkron.'), findsOneWidget);
      expect(find.text('Cari judul catatan'), findsOneWidget);
    });

    testWidgets('menampilkan catatan dari FakeNoteRepository override', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(
              FakeNoteRepository(
                items: [
                  Note(
                    id: 1,
                    title: 'Catatan fake',
                    body: 'Data dari repository test',
                    updatedAt: DateTime(2026, 9, 24),
                    dirty: true,
                  ),
                ],
              ),
            ),
          ],
          child: const OfflineNotesApp(),
        ),
      );

      await tester.pump();

      expect(find.text('Catatan fake'), findsOneWidget);
      expect(find.text('Belum tersinkron'), findsOneWidget);
    });

    testWidgets('menampilkan empty state saat judul tidak cocok', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(
              FakeNoteRepository(
                items: [Note(title: 'Belanja', updatedAt: DateTime.now())],
              ),
            ),
          ],
          child: const OfflineNotesApp(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Kuliah');
      await tester.pump();

      expect(find.text('Tidak ada catatan yang cocok.'), findsOneWidget);
      expect(find.text('Belanja'), findsNothing);
    });

    testWidgets(
      'menolak simpan catatan dengan judul kosong (input tidak valid)',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
            ],
            child: const OfflineNotesApp(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Simpan'));
        await tester.pumpAndSettle();

        expect(find.text('Judul wajib diisi'), findsOneWidget);
      },
    );

    testWidgets('menyimpan catatan baru lalu menampilkannya di daftar', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(FakeNoteRepository()),
          ],
          child: const OfflineNotesApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField),
        'Catatan baru pengujian',
      );
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Catatan baru pengujian'), findsOneWidget);
      expect(find.text('Belum ada catatan.'), findsNothing);
    });

    testWidgets('menampilkan pesan error saat catatan gagal dibaca', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            noteRepositoryProvider.overrideWithValue(
              FakeNoteRepository(throwError: true),
            ),
          ],
          child: const OfflineNotesApp(),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Gagal membaca catatan'), findsOneWidget);
    });
  });
}
