import '../entities/announcement.dart';

abstract interface class AnnouncementsRepository {
  Future<Announcement> getById(String id);
}
