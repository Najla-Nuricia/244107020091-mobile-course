import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson memakai default saat semua field hilang', () {
    /// JSON kosong mewakili respons yang tidak lengkap atau field bernilai null.
    final comment = Comment.fromJson(<String, dynamic>{});

    /// Semua field tetap aman dibaca tanpa null-check di sisi UI.
    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
