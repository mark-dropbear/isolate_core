import '../repositories/thing_repository.dart';

class DeleteThingUseCase {
  final ThingRepository _repository;

  DeleteThingUseCase(this._repository);

  Future<void> call(String name) async {
    return _repository.deleteThing(name);
  }
}
