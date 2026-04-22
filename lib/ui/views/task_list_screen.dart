import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/task_list_viewmodel.dart';

class TaskListScreen extends StatefulWidget {
  final TaskListViewModel viewModel;

  const TaskListScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadTaskLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Task Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Copy all quads to clipboard',
            onPressed: widget.viewModel.copyDatasetToClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.loadTaskLists,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading && widget.viewModel.taskLists.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.error != null && widget.viewModel.taskLists.isEmpty) {
            return Center(child: Text('Error: ${widget.viewModel.error}'));
          }

          final lists = widget.viewModel.taskLists;

          if (lists.isEmpty) {
            return const Center(child: Text('No lists found.'));
          }

          return ListView.builder(
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              return ListTile(
                title: Text(list.displayName),
                subtitle: Text('ID: ${list.name}'),
                onTap: () {
                  final encodedName = Uri.encodeComponent(list.name);
                  context.go('/tasks/$encodedName', extra: list.displayName);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Task List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Display Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.viewModel.createTaskList(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
