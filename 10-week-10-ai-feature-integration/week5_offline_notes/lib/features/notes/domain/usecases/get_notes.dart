import '../entities/note.dart';
import '../repositories/note_repository.dart';

class GetNotes {
  const GetNotes(this._repository);

  final NoteRepository _repository;

  Future<List<Note>> call() => _repository.fetchNotes();
}
