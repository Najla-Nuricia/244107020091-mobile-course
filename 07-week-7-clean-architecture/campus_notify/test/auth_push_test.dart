import 'package:campus_notify/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routes notification payloads to supported destinations', () {
    expect(routeFromMessage({}), AppRoutes.home);
    expect(routeFromMessage({'route': 'pengumuman/3'}), AppRoutes.home);
    expect(
      routeFromMessage({'route': AppRoutes.announcement('3')}),
      AppRoutes.announcement('3'),
    );
  });

  test('rejects unsupported notification destinations', () {
    expect(routeFromMessage({'route': '/unknown'}), AppRoutes.home);
    expect(
      routeFromMessage({'route': '/pengumuman/3/details'}),
      AppRoutes.home,
    );
    expect(routeFromMessage({'route': 3}), AppRoutes.home);
  });
}
