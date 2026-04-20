import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/usecases/standard_usecases.dart';

import '../../fakes/fake_thing_repository.dart';

void main() {
  group('Thing UseCases', () {
    late FakeThingRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeThingRepository();
    });

    test('ListResourcesUseCase returns items from repository', () async {
      final useCase = ListResourcesUseCase<Thing>(fakeRepo);
      fakeRepo.seed([const Thing(name: 'things/1', displayName: 'Item 1')]);

      final results = await useCase.execute();
      expect(results.length, 1);
      expect(results.first.displayName, 'Item 1');
    });

    test('DeleteResourceUseCase removes item from repository', () async {
      final useCase = DeleteResourceUseCase<Thing>(fakeRepo);
      fakeRepo.seed([const Thing(name: 'things/1', displayName: 'Item 1')]);

      await useCase.execute('things/1');
      final remaining = await fakeRepo.listResources();
      expect(remaining, isEmpty);
    });

    group('SaveResourceUseCase', () {
      test('creates a new thing if existingThing is null', () async {
        final useCase = SaveResourceUseCase<Thing>(fakeRepo);

        await useCase.execute(const Thing(name: '', displayName: 'New Thing'), isCreate: true);

        final results = await fakeRepo.listResources();
        expect(results.length, 1);
        expect(results.first.displayName, 'New Thing');
        expect(results.first.name, startsWith('things/'));
      });

      test('updates existing thing if existingThing is provided', () async {
        final useCase = SaveResourceUseCase<Thing>(fakeRepo);
        const existingThing = Thing(name: 'things/1', displayName: 'Old Name');
        fakeRepo.seed([existingThing]);

        await useCase.execute(const Thing(name: 'things/1', displayName: 'Updated Name'), isCreate: false);

        final results = await fakeRepo.listResources();
        expect(results.length, 1);
        expect(results.first.name, 'things/1');
        expect(results.first.displayName, 'Updated Name');
      });
    });
  });
}
