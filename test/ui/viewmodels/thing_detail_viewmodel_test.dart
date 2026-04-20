import 'package:flutter_test/flutter_test.dart';
import 'package:isolate_core/api/models/thing.dart';
import 'package:isolate_core/domain/usecases/save_thing_usecase.dart';
import 'package:isolate_core/ui/viewmodels/thing_detail_viewmodel.dart';

import '../../fakes/fake_thing_repository.dart';

void main() {
  group('ThingDetailViewModel', () {
    late FakeThingRepository fakeRepo;
    late ThingDetailViewModel viewModel;

    setUp(() {
      fakeRepo = FakeThingRepository();
      viewModel = ThingDetailViewModel(
        SaveThingUseCase(fakeRepo),
      );
    });

    test('initial state is correct', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('saveThing() creates a new thing when existingThing is null', () async {
      final future = viewModel.saveThing(null, 'New Thing');
      
      expect(viewModel.isLoading, isTrue);
      
      final result = await future;
      
      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);

      final things = await fakeRepo.getThings();
      expect(things.length, 1);
      expect(things.first.displayName, 'New Thing');
    });

    test('saveThing() updates existing thing', () async {
      const existing = Thing(name: 'things/1', displayName: 'Old Name');
      fakeRepo.seed([existing]);

      final result = await viewModel.saveThing(existing, 'New Name');
      
      expect(result, isTrue);
      
      final things = await fakeRepo.getThings();
      expect(things.length, 1);
      expect(things.first.name, 'things/1');
      expect(things.first.displayName, 'New Name');
    });
  });
}
