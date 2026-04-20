import 'package:flutter/material.dart';
import '../../api/models/thing.dart';
import '../viewmodels/thing_list_viewmodel.dart';

class ThingListScreen extends StatefulWidget {
  final ThingListViewModel viewModel;
  final Widget Function(BuildContext context, Thing? thing) formScreenBuilder;

  const ThingListScreen({
    super.key,
    required this.viewModel,
    required this.formScreenBuilder,
  });

  @override
  State<ThingListScreen> createState() => _ThingListScreenState();
}

class _ThingListScreenState extends State<ThingListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadThings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Things API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.loadThings,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading && widget.viewModel.things.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.error != null && widget.viewModel.things.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${widget.viewModel.error}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.viewModel.loadThings,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final things = widget.viewModel.things;

          if (things.isEmpty) {
            return const Center(child: Text('No things found. Add one!'));
          }

          return ListView.builder(
            itemCount: things.length,
            itemBuilder: (context, index) {
              final thing = things[index];
              return ListTile(
                title: Text(thing.displayName),
                subtitle: Text('ID: ${thing.name}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => widget.formScreenBuilder(ctx, thing),
                          ),
                        );
                        widget.viewModel.loadThings();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => widget.viewModel.deleteThing(thing.name),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => widget.formScreenBuilder(ctx, null),
            ),
          );
          widget.viewModel.loadThings();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
