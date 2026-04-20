import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/usecases/delete_thing_usecase.dart';
import 'package:isolate_core/domain/usecases/get_things_usecase.dart';
import 'package:isolate_core/ui/viewmodels/thing_list_viewmodel.dart';

import '../../fakes/fake_thing_repository.dart';

void main() {
  group('ThingListViewModel', () {
    late FakeThingRepository fakeRepo;
    late ThingListViewModel viewModel;

    setUp(() {
      fakeRepo = FakeThingRepository();
      viewModel = ThingListViewModel(
        GetThingsUseCase(fakeRepo),
        DeleteThingUseCase(fakeRepo),
      );
    });

    test('initial state is correct', () {
      expect(viewModel.things, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('loadThings() successfully loads things from repository', () async {
      fakeRepo.seed([
        const Thing(name: 'things/1', displayName: 'Thing 1'),
        const Thing(name: 'things/2', displayName: 'Thing 2'),
      ]);

      // Initially empty
      expect(viewModel.things, isEmpty);

      // Trigger load
      final future = viewModel.loadThings();

      // Should be loading
      expect(viewModel.isLoading, isTrue);

      await future;

      // Loaded
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.things.length, 2);
      expect(viewModel.things[0].displayName, 'Thing 1');
      expect(viewModel.error, isNull);
    });

    test('deleteThing() removes the thing and updates state', () async {
      fakeRepo.seed([const Thing(name: 'things/1', displayName: 'Thing 1')]);
      await viewModel.loadThings();
      expect(viewModel.things.length, 1);

      await viewModel.deleteThing('things/1');

      expect(viewModel.things, isEmpty);

      // Verify the repository was updated
      final repoThings = await fakeRepo.getThings();
      expect(repoThings, isEmpty);
    });
  });
}
