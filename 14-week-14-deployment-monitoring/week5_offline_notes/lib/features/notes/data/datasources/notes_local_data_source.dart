import 'package:sqflite/sqflite.dart';

import '../../../../data/local/db.dart';
import '../models/note_model.dart';

class NotesLocalDataSource {
  NotesLocalDataSource({Future<Database> Function()? openDb})
    : _openDb = openDb ?? openNotesDb;

  final Future<Database> Function() _openDb;

  Future<List<NoteModel>> fetchNotes() async {
    final db = await _openDb();
    final rows = await db.query('notes', orderBy: 'updated_at DESC');
    return rows.map(NoteModel.fromMap).toList();
  }

  Future<NoteModel?> fetchNoteById(int id) async {
    final db = await _openDb();
    final rows = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : NoteModel.fromMap(rows.first);
  }

  Future<NoteModel> addNote({required String title, String body = ''}) async {
    final db = await _openDb();
    final note = NoteModel(
      title: title,
      body: body,
      updatedAt: DateTime.now(),
      dirty: true,
    );
    final id = await db.insert('notes', note.toMap());
    return NoteModel(
      id: id,
      title: note.title,
      body: note.body,
      updatedAt: note.updatedAt,
      dirty: true,
    );
  }

  Future<void> deleteNote(int id) async {
    final db = await _openDb();
    await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String body,
  }) async {
    final db = await _openDb();
    await db.update(
      'notes',
      {
        'title': title,
        'body': body,
        'updated_at': DateTime.now().toIso8601String(),
        'dirty': 1,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> countDirty() async {
    final db = await _openDb();
    final rows = await db.rawQuery(
      'SELECT COUNT(*) AS c FROM notes WHERE dirty = 1',
    );
    return ((rows.first['c'] as num?)?.toInt() ?? 0);
  }

  Future<void> markAllSynced() async {
    final db = await _openDb();
    await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
  }
}
