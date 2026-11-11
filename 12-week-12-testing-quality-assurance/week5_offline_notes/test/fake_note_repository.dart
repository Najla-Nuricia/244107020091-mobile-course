import 'package:week5_offline_notes/features/notes/domain/entities/note.dart';
import 'package:week5_offline_notes/data/repositories/note_repository.dart';

class FakeNoteRepository extends NoteRepository {
  FakeNoteRepository({List<Note> items = const [], this.throwError = false})
    : _items = List<Note>.of(items);

  final List<Note> _items;
  final bool throwError;

  List<Note> get items => _items;

  @override
  Future<List<Note>> fetchNotes() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return List<Note>.of(_items);
  }

  @override
  Future<Note?> fetchNoteById(int id) async {
    if (throwError) throw Exception('db locked (simulasi)');
    for (final note in _items) {
      if (note.id == id) return note;
    }
    return null;
  }

  @override
  Future<Note> addNote({required String title, String body = ''}) async {
    if (throwError) throw Exception('db locked (simulasi)');
    final note = Note(
      id: _items.isEmpty
          ? 1
          : _items.map((n) => n.id ?? 0).reduce((a, b) => a > b ? a : b) + 1,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    _items.add(note);
    return note;
  }

  @override
  Future<void> deleteNote(int id) async {
    if (throwError) throw Exception('db locked (simulasi)');
    _items.removeWhere((note) => note.id == id);
  }

  @override
  Future<void> updateNote({
    required int id,
    required String title,
    required String body,
  }) async {
    if (throwError) throw Exception('db locked (simulasi)');
    final index = _items.indexWhere((note) => note.id == id);
    if (index < 0) return;
    _items[index] = Note(
      id: id,
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
  }

  @override
  Future<int> countDirty() async {
    if (throwError) throw Exception('db locked (simulasi)');
    return _items.where((n) => n.dirty).length;
  }

  @override
  Future<void> markAllSynced() async {
    if (throwError) throw Exception('db locked (simulasi)');
    for (final note in List<Note>.of(_items)) {
      final index = _items.indexWhere((n) => n.id == note.id);
      if (index < 0) continue;
      _items[index] = Note(
        id: note.id,
        title: note.title,
        body: note.body,
        updatedAt: note.updatedAt,
        dirty: false,
      );
    }
  }
}
