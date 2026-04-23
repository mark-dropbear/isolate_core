import '../../api/models/person.dart';
import '../../domain/repositories/person_repository.dart';
import '../../api/models/api_requests.dart';
import '../services/person_api_service.dart';
import 'package:logging/logging.dart';

class PersonRepositoryImpl implements PersonRepository {
  final _logger = Logger('PersonRepositoryImpl');
  final PersonApiService _apiService;

  PersonRepositoryImpl(this._apiService);

  @override
  Future<List<Person>> getPersons() async {
    _logger.info('getPersons()');
    final response = await _apiService.listPersons(const ListPersonsRequest());
    return response.persons;
  }

  @override
  Future<Person> getPerson(String name) async {
    _logger.info('getPerson($name)');
    return _apiService.getPerson(GetPersonRequest(name: name));
  }

  @override
  Future<Person> createPerson(String givenName, String familyName, String jobTitle) async {
    _logger.info('createPerson()');
    final person = Person(name: '', givenName: givenName, familyName: familyName, jobTitle: jobTitle);
    return _apiService.createPerson(CreatePersonRequest(person: person));
  }

  @override
  Future<Person> updatePerson(Person person) async {
    _logger.info('updatePerson(${person.name})');
    return _apiService.updatePerson(
      UpdatePersonRequest(person: person, updateMask: ['givenName', 'familyName', 'jobTitle']),
    );
  }

  @override
  Future<void> deletePerson(String name) async {
    _logger.info('deletePerson($name)');
    return _apiService.deletePerson(DeletePersonRequest(name: name));
  }
}
