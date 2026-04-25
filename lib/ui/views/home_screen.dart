import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/home_screen_viewmodel.dart';

class HomeScreen extends StatefulWidget {
  final HomeScreenViewModel viewModel;

  const HomeScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.loadMetrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: widget.viewModel.loadMetrics,
          )
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.error != null) {
            return Center(child: Text('Error: ${widget.viewModel.error}'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Decide crossAxisCount based on screen width
              int crossAxisCount = 2;
              if (constraints.maxWidth > 800) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 3;
              }

              return GridView.count(
                crossAxisCount: crossAxisCount,
                padding: const EdgeInsets.all(16.0),
                mainAxisSpacing: 16.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 1.2,
                children: [
                  _DashboardCard(
                    title: 'Task Lists',
                    count: widget.viewModel.taskListCount,
                    icon: Icons.checklist,
                    color: Colors.blue,
                    onTap: () => context.go('/lists'),
                  ),
                  _DashboardCard(
                    title: 'People',
                    count: widget.viewModel.personCount,
                    icon: Icons.person,
                    color: Colors.purple,
                    onTap: () => context.go('/persons'),
                  ),
                  _DashboardCard(
                    title: 'Organizations',
                    count: widget.viewModel.organizationCount,
                    icon: Icons.business,
                    color: Colors.orange,
                    onTap: () => context.go('/organizations'),
                  ),
                  _DashboardCard(
                    title: 'Inventory',
                    count: widget.viewModel.thingCount,
                    icon: Icons.build,
                    color: Colors.teal,
                    onTap: () => context.go('/things'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 48, color: color),
              const Spacer(),
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
