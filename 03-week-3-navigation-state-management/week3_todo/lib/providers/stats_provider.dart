import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';

final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final todos = ref.watch(todoListProvider);

  return {
    'total': todos.length,
    'selesai': todos.where((todo) => todo.done).length,
    'belum': todos.where((todo) => !todo.done).length,
  };
});