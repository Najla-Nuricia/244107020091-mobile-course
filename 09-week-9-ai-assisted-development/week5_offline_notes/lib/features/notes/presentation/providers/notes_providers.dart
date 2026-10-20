import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/post.dart';
import '../../../../data/repositories/post_repository.dart';
import '../../../../data/sync.dart';
import '../../../../data/local/db.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/usecases/get_notes.dart';
import '../../data/datasources/notes_local_data_source.dart';
import '../../data/repositories/note_repository_impl.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: 'https://jsonplaceholder.typicode.com',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ),
  );
});

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

final FutureProvider<List<Post>> postsProvider = FutureProvider<List<Post>>((
  ref,
) {
  return loadPostsCacheFirst(
    ref.watch(postRepositoryProvider),
    onPostsUpdated: () async => ref.invalidate(postsProvider),
  );
});

final notesLocalDataSourceProvider = Provider<NotesLocalDataSource>(
  (ref) => NotesLocalDataSource(openDb: openNotesDb),
);

final noteRepositoryProvider = Provider<NoteRepository>(
  (ref) => NoteRepositoryImpl(ref.watch(notesLocalDataSourceProvider)),
);

final getNotesProvider = Provider<GetNotes>(
  (ref) => GetNotes(ref.watch(noteRepositoryProvider)),
);

final notesProvider = FutureProvider<List<Note>>(
  (ref) => ref.watch(getNotesProvider).call(),
);

class NotesSearchQuery extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
}

final notesSearchQueryProvider = NotifierProvider<NotesSearchQuery, String>(
  NotesSearchQuery.new,
);

final dirtyNotesCountProvider = FutureProvider<int>(
  (ref) => ref.watch(noteRepositoryProvider).countDirty(),
);

Future<int> syncNotesAndRefresh(WidgetRef ref) async {
  final count = await syncNotes(ref.read(noteRepositoryProvider));
  ref.invalidate(notesProvider);
  ref.invalidate(dirtyNotesCountProvider);
  return count;
}
