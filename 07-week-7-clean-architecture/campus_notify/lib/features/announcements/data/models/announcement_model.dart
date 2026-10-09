import '../../domain/entities/announcement.dart';

class AnnouncementModel {
  const AnnouncementModel({required this.id});

  final String id;

  factory AnnouncementModel.fromMap(Map<String, Object?> map) {
    final id = map['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Announcement id must be a non-empty string');
    }
    return AnnouncementModel(id: id);
  }

  factory AnnouncementModel.fromEntity(Announcement announcement) {
    return AnnouncementModel(id: announcement.id);
  }

  Map<String, Object?> toMap() => {'id': id};

  Announcement toEntity() => Announcement(id: id);
}
