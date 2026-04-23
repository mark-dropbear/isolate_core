import '../repositories/person_repository.dart';

class DeletePersonUseCase {
  final PersonRepository _repository;

  DeletePersonUseCase(this._repository);

  Future<void> call(String name) {
    return _repository.deletePerson(name);
  }
}
