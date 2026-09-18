import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week4_api/main.dart';
import 'package:week4_api/data/models/post.dart';
import 'package:week4_api/data/providers.dart';

class _TestPostListNotifier extends PostListNotifier {
  @override
  Future<List<Post>> build() async => const [];
}

void main() {
  testWidgets('Posts page renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          postListProvider.overrideWith(_TestPostListNotifier.new),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Posts API'), findsOneWidget);
  });
}
