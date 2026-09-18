import 'package:dio/dio.dart';

import '../models/comment.dart';

/// Repository yang mengisolasi akses HTTP untuk data komentar.
class CommentRepository {
  /// Menerima Dio agar mudah dipakai ulang dan diganti dengan mock saat testing.
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil komentar untuk post tertentu dengan batas waktu 10 detik.
  Future<List<Comment>> fetchComments(int postId) async {
    final response = await _dio.get<List<dynamic>>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    /// Hanya item object yang valid yang diubah menjadi Comment.
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
