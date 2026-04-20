import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/usecases/delete_thing_usecase.dart';
import 'package:isolate_core/domain/usecases/get_things_usecase.dart';
import 'package:isolate_core/domain/usecases/save_thing_usecase.dart';

import '../../fakes/fake_thing_repository.dart';

void main() {
  group('Thing UseCases', () {
    late FakeThingRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeThingRepository();
    });

    test('GetThingsUseCase returns items from repository', () async {
      final useCase = GetThingsUseCase(fakeRepo);
      fakeRepo.seed([const Thing(name: 'things/1', displayName: 'Item 1')]);

      final results = await useCase();
      expect(results.length, 1);
      expect(results.first.displayName, 'Item 1');
    });

    test('DeleteThingUseCase removes item from repository', () async {
      final useCase = DeleteThingUseCase(fakeRepo);
      fakeRepo.seed([const Thing(name: 'things/1', displayName: 'Item 1')]);

      await useCase('things/1');
      final remaining = await fakeRepo.getThings();
      expect(remaining, isEmpty);
    });

    group('SaveThingUseCase', () {
      test('creates a new thing if existingThing is null', () async {
        final useCase = SaveThingUseCase(fakeRepo);

        await useCase(null, 'New Thing');

        final results = await fakeRepo.getThings();
        expect(results.length, 1);
        expect(results.first.displayName, 'New Thing');
        expect(results.first.name, startsWith('things/'));
      });

      test('updates existing thing if existingThing is provided', () async {
        final useCase = SaveThingUseCase(fakeRepo);
        const existingThing = Thing(name: 'things/1', displayName: 'Old Name');
        fakeRepo.seed([existingThing]);

        await useCase(existingThing, 'Updated Name');

        final results = await fakeRepo.getThings();
        expect(results.length, 1);
        expect(results.first.name, 'things/1');
        expect(results.first.displayName, 'Updated Name');
      });
    });
  });
}
