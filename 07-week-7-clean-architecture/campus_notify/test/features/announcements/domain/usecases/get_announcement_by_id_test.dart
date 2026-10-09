import 'package:campus_notify/features/announcements/domain/entities/announcement.dart';
import 'package:campus_notify/features/announcements/domain/failures/announcement_failure.dart';
import 'package:campus_notify/features/announcements/domain/repositories/announcements_repository.dart';
import 'package:campus_notify/features/announcements/domain/usecases/get_announcement_by_id.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAnnouncementsRepository implements AnnouncementsRepository {
  _FakeAnnouncementsRepository({this.failure});

  final AnnouncementNotFoundFailure? failure;
  String? requestedId;

  @override
  Future<Announcement> getById(String id) async {
    requestedId = id;
    if (failure case final error?) throw error;
    return Announcement(id: id);
  }
}

void main() {
  test('returns announcement from repository', () async {
    final repository = _FakeAnnouncementsRepository();
    final useCase = GetAnnouncementById(repository);

    final result = await useCase('3');

    expect(result.id, '3');
    expect(repository.requestedId, '3');
  });

  test('propagates repository failure', () async {
    const failure = AnnouncementNotFoundFailure('missing');
    final repository = _FakeAnnouncementsRepository(failure: failure);
    final useCase = GetAnnouncementById(repository);

    await expectLater(useCase('missing'), throwsA(same(failure)));
    expect(repository.requestedId, 'missing');
  });
}
