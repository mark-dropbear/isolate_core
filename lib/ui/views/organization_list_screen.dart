import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/organization_list_viewmodel.dart';

class OrganizationListScreen extends StatefulWidget {
  final OrganizationListViewModel viewModel;

  const OrganizationListScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<OrganizationListScreen> createState() => _OrganizationListScreenState();
}

class _OrganizationListScreenState extends State<OrganizationListScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadOrganizations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.loadOrganizations,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading && widget.viewModel.organizations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.error != null &&
              widget.viewModel.organizations.isEmpty) {
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
                    onPressed: widget.viewModel.loadOrganizations,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final organizations = widget.viewModel.organizations;

          if (organizations.isEmpty) {
            return const Center(child: Text('No organizations found. Add one!'));
          }

          return ListView.builder(
            itemCount: organizations.length,
            itemBuilder: (context, index) {
              final organization = organizations[index];
              
              return ListTile(
                title: Text(organization.displayName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(organization.type.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (organization.legalName.isNotEmpty) Text(organization.legalName),
                    Text('ID: ${organization.name}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                isThreeLine: organization.legalName.isNotEmpty,
                onTap: () async {
                  await context.push('/organizations/detail', extra: organization);
                  // Reload when coming back to capture any edits
                  widget.viewModel.loadOrganizations();
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        await context.push('/organizations/edit', extra: organization);
                        widget.viewModel.loadOrganizations();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => widget.viewModel.deleteOrganization(organization.name),
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
          await context.push('/organizations/new');
          widget.viewModel.loadOrganizations();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
