import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/post_detail_page.dart';
import 'pages/paged_post_page.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const PagedPostPage()),
      GoRoute(
        path: '/post/:id',
        builder: (context, state) {
          final postId = int.parse(state.pathParameters['id']!);
          return PostDetailPage(postId: postId);
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Week 4 - REST API',
    theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
    routerConfig: _router,
  );
}
