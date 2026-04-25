import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/ui/viewmodels/home_screen_viewmodel.dart';
import 'package:isolate_core/api/models/task_list.dart';
import 'package:isolate_core/api/models/person.dart';
import 'package:isolate_core/api/models/organization.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/usecases/get_task_lists_usecase.dart';
import 'package:isolate_core/domain/usecases/get_persons_usecase.dart';
import 'package:isolate_core/domain/usecases/get_organizations_usecase.dart';
import 'package:isolate_core/domain/usecases/get_things_usecase.dart';

import '../../fakes/fake_task_list_repository.dart';
import '../../fakes/fake_task_repository.dart';
import '../../fakes/fake_person_repository.dart';
import '../../fakes/fake_organization_repository.dart';
import '../../fakes/fake_thing_repository.dart';

void main() {
  group('HomeScreenViewModel Tests', () {
    late FakeTaskListRepository listRepo;
    late FakePersonRepository personRepo;
    late FakeOrganizationRepository orgRepo;
    late FakeThingRepository thingRepo;
    late HomeScreenViewModel viewModel;

    setUp(() {
      listRepo = FakeTaskListRepository(FakeTaskRepository());
      personRepo = FakePersonRepository();
      orgRepo = FakeOrganizationRepository();
      thingRepo = FakeThingRepository();

      viewModel = HomeScreenViewModel(
        GetTaskListsUseCase(listRepo),
        GetPersonsUseCase(personRepo),
        GetOrganizationsUseCase(orgRepo),
        GetThingsUseCase(thingRepo),
      );
    });

    test('loadMetrics fetches counts from all repositories', () async {
      // Seed data
      listRepo.seed([
        const TaskList(name: 'lists/1', displayName: 'L1'),
        const TaskList(name: 'lists/2', displayName: 'L2'),
      ]);
      personRepo.seed([
        Person(name: 'persons/1', givenName: 'John', familyName: 'Doe'),
      ]);
      orgRepo.seed([
        Organization(name: 'orgs/1', displayName: 'Acme Corp', legalName: 'Acme Corp'),
        Organization(name: 'orgs/2', displayName: 'Globex', legalName: 'Globex'),
        Organization(name: 'orgs/3', displayName: 'Initech', legalName: 'Initech'),
      ]);
      // Leave things empty

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.taskListCount, 0);

      final future = viewModel.loadMetrics();
      expect(viewModel.isLoading, isTrue);

      await future;

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.taskListCount, 2);
      expect(viewModel.personCount, 1);
      expect(viewModel.organizationCount, 3);
      expect(viewModel.thingCount, 0);
      expect(viewModel.error, isNull);
    });
  });
}
