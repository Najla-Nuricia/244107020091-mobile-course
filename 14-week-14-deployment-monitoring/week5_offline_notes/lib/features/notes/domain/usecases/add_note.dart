import '../entities/note.dart';
import '../repositories/note_repository.dart';

class AddNote {
  const AddNote(this._repository);

  final NoteRepository _repository;

  Future<Note> call({required String title, String body = ''}) {
    return _repository.addNote(title: title, body: body);
  }
}
