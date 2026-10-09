import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/announcements/presentation/pages/announcement_page.dart';
import 'features/announcements/presentation/pages/home_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/providers/auth_providers.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const announcementPath = '/pengumuman/:id';
  static const announcementPrefix = '/pengumuman/';

  static String announcement(String id) => '$announcementPrefix$id';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = ref.watch(authRouterRefreshProvider);
  final router = GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: authRefresh,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      return authRouteRedirect(
        isAuthenticated: authState.asData?.value ?? false,
        isLoading: authState.isLoading,
        uri: state.uri,
      );
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.announcementPath,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return AnnouncementPage(id: id);
        },
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});

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
