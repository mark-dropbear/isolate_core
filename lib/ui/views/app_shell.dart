import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    
    int selectedIndex = 0;
    if (location == '/') {
      selectedIndex = 0;
    } else if (location.startsWith('/lists') || location.startsWith('/tasks')) {
      selectedIndex = 1;
    } else if (location.startsWith('/persons')) {
      selectedIndex = 2;
    } else if (location.startsWith('/organizations')) {
      selectedIndex = 3;
    } else if (location.startsWith('/things')) {
      selectedIndex = 4;
    }

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              if (index == 0) {
                context.go('/');
              } else if (index == 1) {
                context.go('/lists');
              } else if (index == 2) {
                context.go('/persons');
              } else if (index == 3) {
                context.go('/organizations');
              } else if (index == 4) {
                context.go('/things');
              }
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.checklist_rtl_outlined),
                selectedIcon: Icon(Icons.checklist_rtl),
                label: Text('Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('People'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business_outlined),
                selectedIcon: Icon(Icons.business),
                label: Text('Orgs'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.build_outlined),
                selectedIcon: Icon(Icons.build),
                label: Text('Things'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: child),
        ],
      ),
    );
  }
}
