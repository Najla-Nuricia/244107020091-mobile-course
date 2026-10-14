import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();
  if (dirtyCount == 0) return 0;

  await Future<void>.delayed(const Duration(seconds: 1));
  await repo.markAllSynced();
  return dirtyCount;
}

Future<List<Post>> readCachedPosts({
  Future<Database> Function()? openDb,
}) async {
  final db = await (openDb ?? openNotesDb)();
  final rows = await db.query('cached_posts', orderBy: 'id ASC');
  return rows.map((row) {
    final payload = jsonDecode(row['payload'] as String);
    return Post.fromJson(Map<String, dynamic>.from(payload as Map));
  }).toList();
}

Future<void> saveCachedPosts(
  List<Post> posts, {
  Future<Database> Function()? openDb,
}) async {
  final db = await (openDb ?? openNotesDb)();
  await db.transaction((transaction) async {
    await transaction.delete('cached_posts');
    final batch = transaction.batch();
    for (final post in posts) {
      batch.insert('cached_posts', {
        'id': post.id,
        'payload': jsonEncode(post.toJson()),
        'cached_at': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit(noResult: true);
  });
}

Future<List<Post>> loadPostsCacheFirst(
  PostRepository repo, {
  Future<Database> Function()? openDb,
  Future<void> Function()? onPostsUpdated,
}) async {
  final cached = await readCachedPosts(openDb: openDb);
  unawaited(() async {
    try {
      final posts = await repo.fetchPosts();
      await saveCachedPosts(posts, openDb: openDb);
      await onPostsUpdated?.call();
    } catch (_) {
      // Cache-first reads remain available when the network is unavailable.
    }
  }());
  return cached;
}
