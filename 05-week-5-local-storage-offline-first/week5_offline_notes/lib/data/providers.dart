import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'repositories/post_repository.dart';

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
      return PostRepository(
        ref.watch(dioProvider),
        onPostsUpdated: () async => ref.invalidate(postsProvider),
      );
    });

final FutureProvider<List<Post>> postsProvider = FutureProvider<List<Post>>((
  ref,
) {
  return ref.watch(postRepositoryProvider).loadPostsCacheFirst();
});
