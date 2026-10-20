import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/note_detail_page.dart';

GoRouter buildRouter({required Widget home}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => home,
        routes: [
          GoRoute(
            path: 'note/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              if (id == null) return const _InvalidNotePage();
              return NoteDetailPage(noteId: id);
            },
          ),
        ],
      ),
    ],
  );
}

class _InvalidNotePage extends StatelessWidget {
  const _InvalidNotePage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('ID catatan tidak valid.')));
  }
}
