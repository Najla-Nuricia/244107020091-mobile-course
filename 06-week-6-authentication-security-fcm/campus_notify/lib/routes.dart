abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const announcementPath = '/pengumuman/:id';
  static const announcementPrefix = '/pengumuman/';

  static String announcement(String id) => '$announcementPrefix$id';

  static String fromNotificationData(Map<String, dynamic> data) {
    final route = data['route'];
    if (route == home || route == login) return route as String;
    if (route is String &&
        route.startsWith(announcementPrefix) &&
        route.length > announcementPrefix.length &&
        !route.substring(announcementPrefix.length).contains('/')) {
      return route;
    }
    return home;
  }
}
