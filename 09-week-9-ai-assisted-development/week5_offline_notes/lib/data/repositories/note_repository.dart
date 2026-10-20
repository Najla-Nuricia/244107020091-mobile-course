import 'package:sqflite/sqflite.dart';

import '../../features/notes/data/datasources/notes_local_data_source.dart';
import '../../features/notes/data/repositories/note_repository_impl.dart';
import '../../features/notes/domain/repositories/note_repository.dart'
    as domain;

class NoteRepository extends NoteRepositoryImpl implements domain.NoteRepository {
  NoteRepository({Future<Database> Function()? openDb})
    : super(NotesLocalDataSource(openDb: openDb));
}
