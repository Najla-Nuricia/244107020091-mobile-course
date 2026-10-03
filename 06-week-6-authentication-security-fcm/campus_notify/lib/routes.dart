abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const announcementPath = '/pengumuman/:id';
  static const announcementPrefix = '/pengumuman/';

  static String announcement(String id) => '$announcementPrefix$id';
}

String routeFromMessage(Map<String, dynamic> data) {
  final route = data['route'];
  if (route is String &&
      (route == AppRoutes.home || route == AppRoutes.login)) {
    return route;
  }

  if (route is String &&
      route.startsWith(AppRoutes.announcementPrefix) &&
      route.length > AppRoutes.announcementPrefix.length &&
      !route.substring(AppRoutes.announcementPrefix.length).contains('/')) {
    return route;
  }

  return AppRoutes.home;
}
