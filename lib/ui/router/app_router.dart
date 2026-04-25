import 'package:go_router/go_router.dart';
import 'package:isolate_core/domain/usecases/get_task_lists_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_list_usecase.dart';
import 'package:isolate_core/domain/usecases/get_tasks_for_list_usecase.dart';
import 'package:isolate_core/domain/usecases/save_task_usecase.dart';
import 'package:isolate_core/domain/usecases/add_task_to_list_usecase.dart';
import 'package:isolate_core/domain/usecases/get_things_usecase.dart';
import 'package:isolate_core/domain/usecases/delete_thing_usecase.dart';
import 'package:isolate_core/domain/usecases/save_thing_usecase.dart';
import 'package:isolate_core/domain/usecases/get_persons_usecase.dart';
import 'package:isolate_core/domain/usecases/delete_person_usecase.dart';
import 'package:isolate_core/domain/usecases/save_person_usecase.dart';
import 'package:isolate_core/domain/usecases/get_organizations_usecase.dart';
import 'package:isolate_core/domain/usecases/delete_organization_usecase.dart';
import 'package:isolate_core/domain/usecases/save_organization_usecase.dart';
import 'package:isolate_core/data/services/debug_api_service.dart';
import 'package:isolate_core/ui/viewmodels/task_list_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/task_screen_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/thing_list_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/thing_detail_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/person_list_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/person_form_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/organization_list_viewmodel.dart';
import 'package:isolate_core/ui/viewmodels/organization_form_viewmodel.dart';
import 'package:isolate_core/ui/views/task_list_screen.dart';
import 'package:isolate_core/ui/views/task_screen.dart';
import 'package:isolate_core/ui/views/thing_list_screen.dart';
import 'package:isolate_core/ui/views/thing_form_screen.dart';
import 'package:isolate_core/ui/views/person_list_screen.dart';
import 'package:isolate_core/ui/views/person_form_screen.dart';
import 'package:isolate_core/ui/views/person_detail_screen.dart';
import 'package:isolate_core/ui/views/organization_list_screen.dart';
import 'package:isolate_core/ui/views/organization_form_screen.dart';
import 'package:isolate_core/ui/views/organization_detail_screen.dart';
import 'package:isolate_core/ui/views/task_detail_screen.dart';
import 'package:isolate_core/ui/views/app_shell.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/api/models/person.dart';
import 'package:isolate_core/api/models/organization.dart';

GoRouter createAppRouter({
  required GetTaskListsUseCase getTaskListsUseCase,
  required SaveTaskListUseCase saveTaskListUseCase,
  required GetTasksForListUseCase getTasksForListUseCase,
  required SaveTaskUseCase saveTaskUseCase,
  required AddTaskToListUseCase addTaskToListUseCase,
  required DebugApiService debugApiService,
  required GetThingsUseCase getThingsUseCase,
  required DeleteThingUseCase deleteThingUseCase,
  required SaveThingUseCase saveThingUseCase,
  required GetPersonsUseCase getPersonsUseCase,
  required DeletePersonUseCase deletePersonUseCase,
  required SavePersonUseCase savePersonUseCase,
  required GetOrganizationsUseCase getOrganizationsUseCase,
  required DeleteOrganizationUseCase deleteOrganizationUseCase,
  required SaveOrganizationUseCase saveOrganizationUseCase,
}) {
  // Instantiate ViewModels once to prevent loss of state during GoRouter rebuilds
  final taskListViewModel = TaskListViewModel(
    getTaskListsUseCase,
    saveTaskListUseCase,
    debugApiService,
  );

  final thingListViewModel = ThingListViewModel(
    getThingsUseCase,
    deleteThingUseCase,
  );
  
  final personListViewModel = PersonListViewModel(
    getPersonsUseCase,
    deletePersonUseCase,
  );

  final organizationListViewModel = OrganizationListViewModel(
    getOrganizationsUseCase,
    deleteOrganizationUseCase,
  );

  // We can reuse the same detail/screen viewmodels since their state is refreshed via load() methods or they are short-lived.
  final taskScreenViewModel = TaskScreenViewModel(
    getTasksForListUseCase,
    saveTaskUseCase,
    addTaskToListUseCase,
    getThingsUseCase,
    getPersonsUseCase,
    getOrganizationsUseCase,
  );

  final thingDetailViewModel = ThingDetailViewModel(saveThingUseCase);
  final personFormViewModel = PersonFormViewModel(savePersonUseCase, getOrganizationsUseCase);
  final organizationFormViewModel = OrganizationFormViewModel(saveOrganizationUseCase, getPersonsUseCase);

  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => TaskListScreen(
              viewModel: taskListViewModel,
            ),
          ),
          GoRoute(
            path: '/tasks/:listName',
            builder: (context, state) {
              final encodedListName = state.pathParameters['listName']!;
              final listName = Uri.decodeComponent(encodedListName);
              final displayName = state.extra as String? ?? 'Tasks';
              return TaskScreen(
                viewModel: taskScreenViewModel,
                listName: listName,
                listDisplayName: displayName,
              );
            },
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final payload = state.extra as TaskDetailPayload;
                  return TaskDetailScreen(payload: payload);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/things',
            builder: (context, state) => ThingListScreen(
              viewModel: thingListViewModel,
            ),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => ThingFormScreen(
                  viewModel: thingDetailViewModel,
                ),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final thing = state.extra as Thing?;
                  return ThingFormScreen(
                    viewModel: thingDetailViewModel,
                    thing: thing,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/persons',
            builder: (context, state) => PersonListScreen(
              viewModel: personListViewModel,
            ),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final person = state.extra as Person;
                  return PersonDetailScreen(person: person);
                },
              ),
              GoRoute(
                path: 'new',
                builder: (context, state) => PersonFormScreen(
                  viewModel: personFormViewModel,
                ),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final person = state.extra as Person?;
                  return PersonFormScreen(
                    viewModel: personFormViewModel,
                    person: person,
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: '/organizations',
            builder: (context, state) => OrganizationListScreen(
              viewModel: organizationListViewModel,
            ),
            routes: [
              GoRoute(
                path: 'detail',
                builder: (context, state) {
                  final organization = state.extra as Organization;
                  return OrganizationDetailScreen(organization: organization);
                },
              ),
              GoRoute(
                path: 'new',
                builder: (context, state) => OrganizationFormScreen(
                  viewModel: organizationFormViewModel,
                ),
              ),
              GoRoute(
                path: 'edit',
                builder: (context, state) {
                  final organization = state.extra as Organization?;
                  return OrganizationFormScreen(
                    viewModel: organizationFormViewModel,
                    organization: organization,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
