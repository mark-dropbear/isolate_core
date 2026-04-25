import 'package:flutter/material.dart';
import '../../api/models/task.dart';
import '../../api/models/thing.dart';
import '../../api/models/person.dart';
import '../../api/models/organization.dart';

class TaskDetailPayload {
  final Task task;
  final List<Thing> availableThings;
  final List<Person> availablePersons;
  final List<Organization> availableOrganizations;

  const TaskDetailPayload({
    required this.task,
    required this.availableThings,
    required this.availablePersons,
    required this.availableOrganizations,
  });
}

class TaskDetailScreen extends StatelessWidget {
  final TaskDetailPayload payload;

  const TaskDetailScreen({
    super.key,
    required this.payload,
  });

  @override
  Widget build(BuildContext context) {
    final task = payload.task;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.displayName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    Chip(
                      label: Text(
                        task.isCompleted ? 'Completed' : 'Potential',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: task.isCompleted
                          ? Colors.green.withValues(alpha: 0.2)
                          : Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow(context, 'Resource Name', task.name),
                _buildDetailRow(
                    context, 'Description', task.description.isNotEmpty ? task.description : 'Not specified'),
                if (task.isCompleted && task.endTime != null)
                  _buildDetailRow(context, 'Completed At', task.endTime!.toLocal().toString()),
                if (task.instruments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInstrumentsRow(context, task.instruments),
                ],
                if (task.agents.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildAgentsRow(context, task.agents),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstrumentsRow(BuildContext context, List<String> instruments) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Instruments',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: instruments.map((instrumentName) {
                final thing = payload.availableThings
                    .where((t) => t.name == instrumentName)
                    .firstOrNull;
                return Chip(
                  avatar: const Icon(Icons.build, size: 16),
                  label: Text(thing?.displayName ?? instrumentName.split('/').last),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentsRow(BuildContext context, List<String> agents) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Agents',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: agents.map((agentName) {
                final person = payload.availablePersons
                    .where((p) => p.name == agentName)
                    .firstOrNull;
                final org = payload.availableOrganizations
                    .where((o) => o.name == agentName)
                    .firstOrNull;
                String display = agentName.split('/').last;
                IconData icon = Icons.person;
                if (person != null) {
                  display = [person.givenName, person.familyName]
                      .where((s) => s.isNotEmpty)
                      .join(' ');
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
          ),
        ],
      ),
    );
  }
}
