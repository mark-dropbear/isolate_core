import '../../api/models/thing.dart';
import '../repositories/thing_repository.dart';

class GetThingsUseCase {
  final ThingRepository _repository;

  GetThingsUseCase(this._repository);

  Future<List<Thing>> call() async {
    return _repository.getThings();
  }
}
