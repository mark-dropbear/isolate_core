import 'package:flutter/material.dart';
import '../viewmodels/task_screen_viewmodel.dart';

class TaskScreen extends StatefulWidget {
  final TaskScreenViewModel viewModel;
  final String listName;
  final String listDisplayName;

  const TaskScreen({
    super.key,
    required this.viewModel,
    required this.listName,
    required this.listDisplayName,
  });

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadTasks(widget.listName);
    widget.viewModel.loadAvailableThings();
    widget.viewModel.loadAvailableAgents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listDisplayName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.viewModel.loadTasks(widget.listName),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading && widget.viewModel.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.error != null && widget.viewModel.tasks.isEmpty) {
            return Center(child: Text('Error: ${widget.viewModel.error}'));
          }

          final tasks = widget.viewModel.tasks;

          if (tasks.isEmpty) {
            return const Center(child: Text('No tasks in this list.'));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (_) => widget.viewModel.toggleTaskStatus(task),
                ),
                title: Text(
                  task.displayName,
                  style: TextStyle(
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task.description.isNotEmpty) Text(task.description),
                    if (task.instruments.isNotEmpty)
                      Wrap(
                        spacing: 4.0,
                        children: task.instruments.map((instrumentName) {
                          // Simple lookup for display name from available things
                          final thing = widget.viewModel.availableThings.where((t) => t.name == instrumentName).firstOrNull;
                          return Chip(
                            avatar: const Icon(Icons.build, size: 16),
                            label: Text(thing?.displayName ?? instrumentName.split('/').last),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    if (task.agents.isNotEmpty)
                      Wrap(
                        spacing: 4.0,
                        children: task.agents.map((agentName) {
                          // Combine searches for agent display name
                          final person = widget.viewModel.availablePersons.where((p) => p.name == agentName).firstOrNull;
                          final org = widget.viewModel.availableOrganizations.where((o) => o.name == agentName).firstOrNull;
                          String display = agentName.split('/').last;
                          IconData icon = Icons.person;
                          if (person != null) {
                            display = [person.givenName, person.familyName].where((s) => s.isNotEmpty).join(' ');
                            if (display.isEmpty) display = 'Unknown Person';
                          } else if (org != null) {
                            display = org.displayName;
                            icon = Icons.business;
                          }
                          return Chip(
                            avatar: Icon(icon, size: 16),
                            label: Text(display),
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (ctx) => CreateTaskDialog(
              viewModel: widget.viewModel,
              listName: widget.listName,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CreateTaskDialog extends StatefulWidget {
  final TaskScreenViewModel viewModel;
  final String listName;

  const CreateTaskDialog({
    super.key,
    required this.viewModel,
    required this.listName,
  });

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _nameController = TextEditingController();
  final Set<String> _selectedInstruments = {};
  final Set<String> _selectedAgents = {};

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Task'),
      content: SingleChildScrollView(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Task Name'),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('Instruments', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (widget.viewModel.availableThings.isEmpty)
                  const Text('No things available to select.')
                else
                  Wrap(
                    spacing: 8.0,
                    children: widget.viewModel.availableThings.map((thing) {
                      final isSelected = _selectedInstruments.contains(thing.name);
                      return FilterChip(
                        label: Text(thing.displayName),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedInstruments.add(thing.name);
                            } else {
                              _selectedInstruments.remove(thing.name);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                const Text('Agents', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (widget.viewModel.availablePersons.isEmpty && widget.viewModel.availableOrganizations.isEmpty)
                  const Text('No agents available to select.')
                else
                  Wrap(
                    spacing: 8.0,
                    children: [
                      ...widget.viewModel.availablePersons.map((person) {
                        final isSelected = _selectedAgents.contains(person.name);
                        final title = [person.givenName, person.familyName].where((s) => s.isNotEmpty).join(' ');
                        final displayTitle = title.isNotEmpty ? title : person.name.split('/').last;
                        return FilterChip(
                          avatar: const Icon(Icons.person, size: 18),
                          label: Text(displayTitle),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAgents.add(person.name);
                              } else {
                                _selectedAgents.remove(person.name);
                              }
                            });
                          },
                        );
                      }),
                      ...widget.viewModel.availableOrganizations.map((org) {
                        final isSelected = _selectedAgents.contains(org.name);
                        return FilterChip(
                          avatar: const Icon(Icons.business, size: 18),
                          label: Text(org.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedAgents.add(org.name);
                              } else {
                                _selectedAgents.remove(org.name);
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              widget.viewModel.addTask(
                widget.listName,
                _nameController.text,
                instruments: _selectedInstruments.toList(),
                agents: _selectedAgents.toList(),
              );
            }
            Navigator.pop(context);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
