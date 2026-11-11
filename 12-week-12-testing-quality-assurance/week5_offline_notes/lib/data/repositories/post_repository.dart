import 'package:dio/dio.dart';

import '../models/post.dart';

class PostRepository {
  PostRepository(this._dio);

  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List<dynamic>>('/posts');
    final data = response.data ?? const <dynamic>[];
    return data
        .whereType<Map>()
        .map((json) => Post.fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }
}
