import '../entities/note.dart';

abstract interface class NoteRepository {
  Future<List<Note>> fetchNotes();
  Future<Note?> fetchNoteById(int id);
  Future<Note> addNote({required String title, String body = ''});
  Future<void> deleteNote(int id);
  Future<void> updateNote({
    required int id,
    required String title,
    required String body,
  });
  Future<int> countDirty();
  Future<void> markAllSynced();
}
