import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';

final unfinishedTodosProvider = Provider<List<Todo>>((ref) {
  // digunakan untuk melihat isi kotak berubah atau enggak
  final todos = ref.watch(todoListProvider);
  //untuk return yang belum selesai
  return todos.where((todo) => !todo.done).toList();
});