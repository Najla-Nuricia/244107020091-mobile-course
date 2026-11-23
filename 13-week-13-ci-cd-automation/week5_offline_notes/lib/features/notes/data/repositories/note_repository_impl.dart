import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/notes_local_data_source.dart';

class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl(this._dataSource);

  final NotesLocalDataSource _dataSource;

  @override
  Future<List<Note>> fetchNotes() => _dataSource.fetchNotes();

  @override
  Future<Note?> fetchNoteById(int id) => _dataSource.fetchNoteById(id);

  @override
  Future<Note> addNote({required String title, String body = ''}) {
    return _dataSource.addNote(title: title, body: body);
  }

  @override
  Future<void> deleteNote(int id) => _dataSource.deleteNote(id);

  @override
  Future<void> updateNote({
    required int id,
    required String title,
    required String body,
  }) {
    return _dataSource.updateNote(id: id, title: title, body: body);
  }

  @override
  Future<int> countDirty() => _dataSource.countDirty();

  @override
  Future<void> markAllSynced() => _dataSource.markAllSynced();
}
