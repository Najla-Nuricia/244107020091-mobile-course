import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../models/post.dart';

class PostRepository {
  PostRepository(
    this._dio, {
    Future<Database> Function()? openDb,
    this.onPostsUpdated,
  }) : _openDb = openDb ?? openNotesDb;

  final Dio _dio;
  final Future<Database> Function() _openDb;
  final Future<void> Function()? onPostsUpdated;
  bool _backgroundRefreshRequested = false;

  Future<List<Post>> readCachedPosts() async {
    final db = await _openDb();
    final rows = await db.query('cached_posts', orderBy: 'id ASC');
    return rows.map((row) {
      final payload = jsonDecode(row['payload'] as String);
      return Post.fromJson(Map<String, dynamic>.from(payload as Map));
    }).toList();
  }

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List<dynamic>>('/posts');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((json) => Post.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> saveCachedPosts(List<Post> posts) async {
    final db = await _openDb();
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

  Future<void> refreshPostsInBackground() async {
    try {
      final posts = await fetchPosts();
      await saveCachedPosts(posts);
      await onPostsUpdated?.call();
    } catch (_) {
      // Cache-first reads remain usable when the network is unavailable.
    }
  }

  Future<List<Post>> loadPostsCacheFirst() async {
    final cached = await readCachedPosts();
    if (!_backgroundRefreshRequested) {
      _backgroundRefreshRequested = true;
      unawaited(refreshPostsInBackground());
    }
    return cached;
  }
}
