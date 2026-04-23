import '../../api/models/person.dart';
import '../repositories/person_repository.dart';

class GetPersonsUseCase {
  final PersonRepository _repository;

  GetPersonsUseCase(this._repository);

  Future<List<Person>> call() {
    return _repository.getPersons();
  }
}
