import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/models/person.dart';
import '../viewmodels/person_form_viewmodel.dart';

class PersonFormScreen extends StatefulWidget {
  final PersonFormViewModel viewModel;
  final Person? person;

  const PersonFormScreen({
    super.key,
    required this.viewModel,
    this.person,
  });

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  late final TextEditingController _givenNameController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _jobTitleController;

  @override
  void initState() {
    super.initState();
    _givenNameController =
        TextEditingController(text: widget.person?.givenName ?? '');
    _familyNameController =
        TextEditingController(text: widget.person?.familyName ?? '');
    _jobTitleController =
        TextEditingController(text: widget.person?.jobTitle ?? '');
  }

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    _jobTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.person != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Person' : 'New Person'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.viewModel.error != null) ...[
                  Text(
                    widget.viewModel.error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _givenNameController,
                  decoration: const InputDecoration(
                    labelText: 'Given Name (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !widget.viewModel.isSaving,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _familyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Family Name (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !widget.viewModel.isSaving,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _jobTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !widget.viewModel.isSaving,
                ),
                const SizedBox(height: 8),
                Text(
                  'Note: At least one field must be populated.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.viewModel.isSaving
                      ? null
                      : () async {
                          final saved = await widget.viewModel.savePerson(
                            name: widget.person?.name,
                            givenName: _givenNameController.text,
                            familyName: _familyNameController.text,
                            jobTitle: _jobTitleController.text,
                          );
                          if (saved != null && context.mounted) {
                            context.pop();
                          }
                        },
                  child: widget.viewModel.isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Save Person'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
