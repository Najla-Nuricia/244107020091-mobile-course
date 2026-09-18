import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dart:async';

import 'api_client.dart';
import 'models/comment.dart';
import 'models/post.dart';
import 'repositories/comment_repository.dart';
import 'repositories/post_repository.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

/// Menyediakan repository komentar dengan Dio yang sama seperti fitur posts.
final commentRepositoryProvider = Provider<CommentRepository>(
  (ref) => CommentRepository(ref.watch(dioProvider)),
);

/// Mengambil komentar secara async untuk satu postId.
class CommentsNotifier extends AsyncNotifier<List<Comment>> {
  /// Menyimpan argumen family agar build dapat memanggil endpoint yang tepat.
  CommentsNotifier(this.postId);

  final int postId;

  @override
  Future<List<Comment>> build() {
    /// Exception dari repository otomatis diubah Riverpod menjadi AsyncError.
    return ref.watch(commentRepositoryProvider).fetchComments(postId);
  }
}

/// Family provider membuat state terpisah untuk setiap postId.
final commentsProvider =
    AsyncNotifierProvider.family<CommentsNotifier, List<Comment>, int>(
      CommentsNotifier.new,
      // Error dikirim langsung sebagai AsyncError agar tidak retry otomatis.
      retry: (retryCount, error) => null,
    );

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    // Exception dari repository otomatis menjadi AsyncError.
    // Inilah ekuivalen deklaratif dari AsyncValue.guard di versi lama.
    final repository = ref.watch(postRepositoryProvider);
    return repository.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final repository = ref.read(postRepositoryProvider);
      state = AsyncData(await repository.fetchPosts());
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Mengambil detail dari cache list jika ada, atau langsung dari repository.
class PostDetailNotifier extends AsyncNotifier<Post> {
  PostDetailNotifier(this.postId);

  final int postId;

  @override
  Future<Post> build() async {
    final listState = ref.read(postListProvider);
    final cachedPosts = listState is AsyncData<List<Post>>
        ? listState.value
        : null;
    final cachedPost = cachedPosts
        ?.where((post) => post.id == postId)
        .firstOrNull;
    return cachedPost ?? ref.read(postRepositoryProvider).fetchPost(postId);
  }
}

/// Provider family memberi state detail yang terpisah untuk setiap post ID.
final postDetailProvider =
    AsyncNotifierProvider.family<PostDetailNotifier, Post, int>(
      PostDetailNotifier.new,
      retry: (retryCount, error) => null,
    );

final postListProvider = AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
  // Nonaktifkan retry otomatis Riverpod 3 agar error langsung
  // final dan mudah diuji (tanpa ini, future provider di-test
  // akan me-retry dan menggantung).
  retry: (retryCount, error) => null,
);

/// Helper khusus testing (letakkan di providers.dart): membaca state
/// pertama yang bukan loading lewat listener + completer, sehingga
/// test tidak menunggu retry dan tidak melakukan HTTP sungguhan.
Future<List<Post>> readPostsOnce(ProviderContainer container) {
  final completer = Completer<List<Post>>();
  final sub = container.listen<AsyncValue<List<Post>>>(postListProvider, (
    previous,
    next,
  ) {
    if (next.isLoading || completer.isCompleted) return;
    next.whenData(completer.complete);
    if (next.hasError) {
      completer.completeError(
        next.error ?? StateError('unknown error'),
        next.stackTrace ?? StackTrace.empty,
      );
    }
  }, fireImmediately: true);
  return completer.future.whenComplete(sub.close);
}

Future<Object?> readPostsErrorOnce(ProviderContainer container) {
  final completer = Completer<Object?>();
  final sub = container.listen<AsyncValue<List<Post>>>(postListProvider, (
    previous,
    next,
  ) {
    if (next.isLoading || completer.isCompleted) return;
    completer.complete(next.error);
  }, fireImmediately: true);
  return completer.future.whenComplete(sub.close);
}
