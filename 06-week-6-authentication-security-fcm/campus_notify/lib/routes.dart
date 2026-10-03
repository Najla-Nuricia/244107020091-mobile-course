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

String? authRouteRedirect({
  required bool isAuthenticated,
  required bool isLoading,
  required Uri uri,
}) {
  if (isLoading) {
    if (uri.path == AppRoutes.login) return null;
    return _loginLocation(uri);
  }

  if (!isAuthenticated && uri.path != AppRoutes.login) {
    return _loginLocation(uri);
  }

  if (isAuthenticated && uri.path == AppRoutes.login) {
    final returnPath = uri.queryParameters['from'];
    if (returnPath != null &&
        returnPath.startsWith('/') &&
        !returnPath.startsWith('//')) {
      return returnPath;
    }
    return AppRoutes.home;
  }

  return null;
}

String _loginLocation(Uri uri) {
  final returnPath = uri.toString() == AppRoutes.home ? null : uri.toString();
  return Uri(
    path: AppRoutes.login,
    queryParameters: returnPath == null ? null : {'from': returnPath},
  ).toString();
}
