import '../../api/models/person.dart';

abstract class PersonRepository {
  Future<List<Person>> getPersons();
  Future<Person> getPerson(String name);
  Future<Person> createPerson(String givenName, String familyName, String jobTitle);
  Future<Person> updatePerson(Person person);
  Future<void> deletePerson(String name);
}
