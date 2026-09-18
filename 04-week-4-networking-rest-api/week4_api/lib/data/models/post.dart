class Post {
  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  final int userId;
  final int id;
  final String title;
  final String body;

  // mengatasi misalkan data JSON tidak lengkap atau null, kita memberikan nilai default untuk setiap field
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
    );
  }

// proses mengubah objek Post menjadi data JSON
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'id': id,
        'title': title,
        'body': body,
      };
}