import 'repositories/note_repository.dart';

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  // Simulate an upload; a real API call would happen before marking synced.
  await Future<void>.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}
