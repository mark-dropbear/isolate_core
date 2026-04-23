import 'package:isolate_core/api/models/person.dart';
import 'package:isolate_core/api/models/resource_name.dart';
import 'package:isolate_core/domain/repositories/person_repository.dart';

class FakePersonRepository implements PersonRepository {
  final List<Person> _persons = [];

  void seed(List<Person> initialPersons) {
    _persons.clear();
    _persons.addAll(initialPersons);
  }

  @override
  Future<List<Person>> getPersons() async {
    return List.from(_persons);
  }

  @override
  Future<Person> getPerson(String name) async {
    return _persons.firstWhere(
      (p) => p.name == name,
      orElse: () => throw Exception('Person not found'),
    );
  }

  @override
  Future<Person> createPerson(String givenName, String familyName, String jobTitle) async {
    final newPerson = Person(
      name: ResourceName.generate('persons').toString(),
      givenName: givenName,
      familyName: familyName,
      jobTitle: jobTitle,
    );
    _persons.add(newPerson);
    return newPerson;
  }

  @override
  Future<Person> updatePerson(Person person) async {
    final index = _persons.indexWhere((p) => p.name == person.name);
    if (index == -1) {
      throw Exception('Person not found');
    }
    _persons[index] = person;
    return person;
  }

  @override
  Future<void> deletePerson(String name) async {
    _persons.removeWhere((p) => p.name == name);
  }
}
