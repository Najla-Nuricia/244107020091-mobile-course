import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/main.dart';
import 'package:week4_api/data/paged_post.dart';

class _TestPagedPostsNotifier extends PagedPostsNotifier {
  @override
  PagedPostsState build() => const PagedPostsState();
}

void main() {
  testWidgets('Posts page renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pagedPostsProvider.overrideWith(_TestPagedPostsNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Posts Paged'), findsOneWidget);
  });
}
