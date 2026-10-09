import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/announcements_repository_impl.dart';
import '../../domain/entities/announcement.dart';
import '../../domain/repositories/announcements_repository.dart';
import '../../domain/usecases/get_announcement_by_id.dart';

final announcementsRepositoryProvider = Provider<AnnouncementsRepository>(
  (ref) => AnnouncementsRepositoryImpl(),
);

final getAnnouncementByIdProvider = Provider<GetAnnouncementById>(
  (ref) => GetAnnouncementById(ref.watch(announcementsRepositoryProvider)),
);

final announcementProvider = FutureProvider.family<Announcement, String>(
  (ref, id) => ref.watch(getAnnouncementByIdProvider)(id),
);
