import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week5_offline_notes/data/local/note.dart';
import 'package:week5_offline_notes/data/providers.dart';
import 'package:week5_offline_notes/main.dart';

import 'fake_note_repository.dart';

void main() {
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
}
