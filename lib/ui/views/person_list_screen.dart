import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/person_list_viewmodel.dart';

class PersonListScreen extends StatefulWidget {
  final PersonListViewModel viewModel;

  const PersonListScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<PersonListScreen> createState() => _PersonListScreenState();
}

class _PersonListScreenState extends State<PersonListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadPersons();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People API'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.loadPersons,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading && widget.viewModel.persons.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.error != null &&
              widget.viewModel.persons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${widget.viewModel.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: widget.viewModel.loadPersons,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final persons = widget.viewModel.persons;

          if (persons.isEmpty) {
            return const Center(child: Text('No people found. Add one!'));
          }

          return ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final person = persons[index];
              final title = [person.givenName, person.familyName]
                  .where((s) => s.isNotEmpty)
                  .join(' ');
              final displayTitle = title.isNotEmpty ? title : 'Unknown Name';
              
              return ListTile(
                title: Text(displayTitle),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (person.jobTitle.isNotEmpty) Text(person.jobTitle),
                    Text('ID: ${person.name}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await context.push('/persons/edit', extra: person);
                        widget.viewModel.loadPersons();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => widget.viewModel.deletePerson(person.name),
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
          await context.push('/persons/new');
          widget.viewModel.loadPersons();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
