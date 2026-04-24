import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/models/organization.dart';
import '../viewmodels/organization_form_viewmodel.dart';

class OrganizationFormScreen extends StatefulWidget {
  final OrganizationFormViewModel viewModel;
  final Organization? organization;

  const OrganizationFormScreen({
    super.key,
    required this.viewModel,
    this.organization,
  });

  @override
  State<OrganizationFormScreen> createState() => _OrganizationFormScreenState();
}

class _OrganizationFormScreenState extends State<OrganizationFormScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _legalNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;
  late OrganizationType _selectedType;

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.organization?.displayName ?? '');
    _legalNameController =
        TextEditingController(text: widget.organization?.legalName ?? '');
    _descriptionController =
        TextEditingController(text: widget.organization?.description ?? '');
    _urlController = TextEditingController(text: widget.organization?.url ?? '');
    _selectedType = widget.organization?.type ?? OrganizationType.organization;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _legalNameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.organization != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Organization' : 'New Organization'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return SingleChildScrollView(
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
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Name (Required)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !widget.viewModel.isSaving,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<OrganizationType>(
                  decoration: const InputDecoration(
                    labelText: 'Organization Type',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedType,
                  items: OrganizationType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.schemaName),
                    );
                  }).toList(),
                  onChanged: widget.viewModel.isSaving
                      ? null
                      : (OrganizationType? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedType = newValue;
                            });
                          }
                        },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _legalNameController,
                  decoration: const InputDecoration(
                    labelText: 'Legal Name (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  enabled: !widget.viewModel.isSaving,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  enabled: !widget.viewModel.isSaving,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _urlController,
                  decoration: const InputDecoration(
                    labelText: 'URL (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                  keyboardType: TextInputType.url,
                  enabled: !widget.viewModel.isSaving,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.viewModel.isSaving
                      ? null
                      : () async {
                          final saved = await widget.viewModel.saveOrganization(
                            name: widget.organization?.name,
                            displayName: _displayNameController.text,
                            type: _selectedType,
                            legalName: _legalNameController.text,
                            description: _descriptionController.text,
                            url: _urlController.text,
                          );
                          if (saved != null && context.mounted) {
                            context.pop();
                          }
                        },
                  child: widget.viewModel.isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Save Organization'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
