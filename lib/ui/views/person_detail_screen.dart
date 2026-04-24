import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/models/person.dart';

class PersonDetailScreen extends StatelessWidget {
  final Person person;

  const PersonDetailScreen({
    super.key,
    required this.person,
  });

  @override
  Widget build(BuildContext context) {
    final title = [person.givenName, person.familyName]
        .where((s) => s.isNotEmpty)
        .join(' ');
    final displayTitle = title.isNotEmpty ? title : 'Unknown Name';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Person Details'),
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
                Text(
                  displayTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow(context, 'Resource Name', person.name),
                _buildDetailRow(context, 'Given Name', person.givenName.isNotEmpty ? person.givenName : 'Not specified'),
                _buildDetailRow(context, 'Family Name', person.familyName.isNotEmpty ? person.familyName : 'Not specified'),
                _buildDetailRow(context, 'Job Title', person.jobTitle.isNotEmpty ? person.jobTitle : 'Not specified'),
                if (person.worksFor.isNotEmpty)
                  _buildDetailRow(context, 'Works For', person.worksFor.join(', ')),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/persons/edit', extra: person);
          // Note: Since we are passing the object via extra and not fetching it,
          // changes won't be reflected immediately when we pop back to this screen
          // unless we fetch the updated person. For a robust app, we'd listen to updates
          // or reload. To keep it simple, we just pop to the list view or 
          // accept that edits might require a list refresh.
        },
        child: const Icon(Icons.edit),
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
}
