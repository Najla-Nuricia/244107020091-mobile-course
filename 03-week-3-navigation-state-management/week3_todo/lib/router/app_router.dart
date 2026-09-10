import 'package:go_router/go_router.dart';
import '../providers/todo_page.dart';
import '../providers/stats_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TodoPage(),
    ),
    GoRoute(
      path: '/stats',
      builder: (context, state) => const StatsPage(),
    )
  ],
);