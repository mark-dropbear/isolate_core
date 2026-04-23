import '../../api/models/person.dart';
import '../repositories/person_repository.dart';

class SavePersonUseCase {
  final PersonRepository _repository;

  SavePersonUseCase(this._repository);

  Future<Person> call(Person person) async {
    if (person.name.isEmpty) {
      return _repository.createPerson(
        person.givenName,
        person.familyName,
        person.jobTitle,
      );
    } else {
      return _repository.updatePerson(person);
    }
  }
}
