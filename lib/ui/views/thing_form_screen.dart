import 'package:flutter/material.dart';
import '../../api/models/thing.dart';
import '../viewmodels/thing_detail_viewmodel.dart';

class ThingFormScreen extends StatefulWidget {
  final ThingDetailViewModel viewModel;
  final Thing? thing;

  const ThingFormScreen({super.key, required this.viewModel, this.thing});

  @override
  State<ThingFormScreen> createState() => _ThingFormScreenState();
}

class _ThingFormScreenState extends State<ThingFormScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.thing?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.thing == null ? 'Create Thing' : 'Edit Thing'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (widget.viewModel.error != null) ...[
                  Text(
                    'Error: ${widget.viewModel.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    border: OutlineInputBorder(),
                  ),
                  enabled: !widget.viewModel.isLoading,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.viewModel.isLoading
                        ? null
                        : () async {
                            if (_nameController.text.trim().isEmpty) return;
                            final success = await widget.viewModel.saveThing(
                              widget.thing,
                              _nameController.text.trim(),
                            );
                            if (success && context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                    child: widget.viewModel.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
