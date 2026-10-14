import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local/note.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';
import 'sync.dart';

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

final Provider<PostRepository> postRepositoryProvider =
    Provider<PostRepository>((ref) {
      return PostRepository(ref.watch(dioProvider));
    });

final FutureProvider<List<Post>> postsProvider = FutureProvider<List<Post>>((
  ref,
) {
  return loadPostsCacheFirst(
    ref.watch(postRepositoryProvider),
    onPostsUpdated: () async => ref.invalidate(postsProvider),
  );
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository();
});

final notesProvider = FutureProvider<List<Note>>((ref) {
  return ref.watch(noteRepositoryProvider).fetchNotes();
});

final dirtyNotesCountProvider = FutureProvider<int>((ref) {
  return ref.watch(noteRepositoryProvider).countDirty();
});

Future<int> syncNotesAndRefresh(WidgetRef ref) async {
  final count = await syncNotes(ref.read(noteRepositoryProvider));
  ref.invalidate(notesProvider);
  ref.invalidate(dirtyNotesCountProvider);
  return count;
}
