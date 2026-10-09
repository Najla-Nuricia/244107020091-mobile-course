import '../../domain/entities/announcement.dart';
import '../../domain/failures/announcement_failure.dart';
import '../../domain/repositories/announcements_repository.dart';
import '../models/announcement_model.dart';

class AnnouncementsRepositoryImpl implements AnnouncementsRepository {
  static const _records = <String, Map<String, Object?>>{
    '3': {'id': '3'},
  };

  @override
  Future<Announcement> getById(String id) async {
    final record = _records[id];
    if (record == null) throw AnnouncementNotFoundFailure(id);
    return AnnouncementModel.fromMap(record).toEntity();
  }
}
