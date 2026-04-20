import '../../api/models/thing.dart';
import '../repositories/thing_repository.dart';

class SaveThingUseCase {
  final ThingRepository _repository;

  SaveThingUseCase(this._repository);

  Future<Thing> call(Thing? existingThing, String displayName) async {
    if (existingThing == null) {
      return _repository.createThing(displayName);
    } else {
      return _repository.updateThing(existingThing.copyWith(displayName: displayName));
    }
  }
}
