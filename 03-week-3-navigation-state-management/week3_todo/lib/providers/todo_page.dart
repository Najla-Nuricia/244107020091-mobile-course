import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_provider.dart';
import 'todo_tile.dart';
import 'todo_filter_provider.dart';

class TodoPage extends ConsumerWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(unfinishedTodosProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ToDo Riverpod')),
      body: todos.isEmpty
          ? const Center(child: Text('Belum ada tugas'))
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) 
              =>TodoTile(
                todo: todos[index],
                onToggle: () {
                  //ambil semua todo asli
                  final allTodos = ref.read(todoListProvider);
                  //cari todo yang di klik ada di index berapa
                  final todoIndex = allTodos.indexOf(todos[index]);
                  //toggle
                  ref.read(todoListProvider.notifier).toggle(todoIndex);
                },
                onDelete: () {
                  final allTodos = ref.read(todoListProvider);
                  final todoIndex = allTodos.indexOf(todos[index]);
                  ref.read(todoListProvider.notifier).remove(todoIndex);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tugas baru'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(todoListProvider.notifier)
                    .add(controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }
}