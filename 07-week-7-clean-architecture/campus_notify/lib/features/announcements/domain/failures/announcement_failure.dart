import '../../../../core/failures.dart';

class AnnouncementNotFoundFailure extends Failure {
  const AnnouncementNotFoundFailure(String id)
    : super('Pengumuman dengan ID $id tidak ditemukan.');
}
