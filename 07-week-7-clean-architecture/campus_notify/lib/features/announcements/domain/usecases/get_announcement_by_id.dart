import '../entities/announcement.dart';
import '../repositories/announcements_repository.dart';

class GetAnnouncementById {
  const GetAnnouncementById(this._repository);

  final AnnouncementsRepository _repository;

  Future<Announcement> call(String id) => _repository.getById(id);
}
