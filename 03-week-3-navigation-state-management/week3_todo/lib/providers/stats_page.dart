import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final todos = ref.watch(todoListProvider);
    final totalTodos = todos.length;
    final completedTodos = todos.where((todo) => todo.done).length;
    final uncompletedTodos = todos.where((todo) => !todo.done).length;

    return Scaffold(
      appBar:AppBar(
        title: const Text('Stats'),
        ),
        body: Padding(padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Tugas: $totalTodos'),
            const SizedBox(height: 8),
            Text('Tugas Selesai: $completedTodos'),
            const SizedBox(height: 8),
            Text('Tugas Belum Selesai: $uncompletedTodos'),
          ],
        ),
      ),
    ); 
  }
}