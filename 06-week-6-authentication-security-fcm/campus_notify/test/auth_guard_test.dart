import 'package:campus_notify/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'unauthenticated deep links redirect to login and preserve destination',
    () {
      final redirect = authRouteRedirect(
        isAuthenticated: false,
        isLoading: false,
        uri: Uri.parse('/pengumuman/3'),
      );

      expect(Uri.parse(redirect!).path, AppRoutes.login);
      expect(Uri.parse(redirect).queryParameters['from'], '/pengumuman/3');
    },
  );

  test('authenticated login returns to the saved internal route', () {
    expect(
      authRouteRedirect(
        isAuthenticated: true,
        isLoading: false,
        uri: Uri.parse('/login?from=%2Fpengumuman%2F3'),
      ),
      '/pengumuman/3',
    );
  });

  test(
    'loading sessions guard deep links and external return paths are rejected',
    () {
      expect(
        authRouteRedirect(
          isAuthenticated: false,
          isLoading: true,
          uri: Uri.parse('/pengumuman/3'),
        ),
        '/login?from=%2Fpengumuman%2F3',
      );
      expect(
        authRouteRedirect(
          isAuthenticated: true,
          isLoading: false,
          uri: Uri.parse('/login?from=%2F%2Fevil.example'),
        ),
        AppRoutes.home,
      );
    },
  );
}
