import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/person.dart';
import '../../domain/usecases/get_persons_usecase.dart';
import '../../domain/usecases/delete_person_usecase.dart';

class PersonListViewModel extends ChangeNotifier {
  final _logger = Logger('PersonListViewModel');
  final GetPersonsUseCase _getPersons;
  final DeletePersonUseCase _deletePerson;

  List<Person> persons = [];
  bool isLoading = false;
  String? error;

  PersonListViewModel(this._getPersons, this._deletePerson);

  Future<void> loadPersons() async {
    _logger.info('Loading persons');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      persons = await _getPersons();
      _logger.info('Successfully loaded ${persons.length} persons');
    } catch (e, stackTrace) {
      _logger.severe('Failed to load persons', e, stackTrace);
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePerson(String name) async {
    _logger.info('Deleting person $name');
    try {
      await _deletePerson(name);
      persons.removeWhere((p) => p.name == name);
      _logger.info('Successfully deleted person $name');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Failed to delete person $name', e, stackTrace);
      error = e.toString();
      notifyListeners();
    }
  }
}
