import 'package:flutter_test/flutter_test.dart';

import 'package:campus_notify/routes.dart';

void main() {
  test('uses the notification route when it matches a supported route', () {
    expect(routeFromMessage({'route': AppRoutes.login}), AppRoutes.login);
    expect(
      routeFromMessage({'route': AppRoutes.announcement('3')}),
      AppRoutes.announcement('3'),
    );
  });

  test('falls back home for missing or invalid routes', () {
    expect(routeFromMessage({}), AppRoutes.home);
    expect(routeFromMessage({'route': '/unknown'}), AppRoutes.home);
    expect(
      routeFromMessage({'route': '/pengumuman/3/details'}),
      AppRoutes.home,
    );
    expect(routeFromMessage({'route': 3}), AppRoutes.home);
  });
}
