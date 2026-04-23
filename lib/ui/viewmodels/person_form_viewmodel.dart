import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/person.dart';
import '../../domain/usecases/save_person_usecase.dart';

class PersonFormViewModel extends ChangeNotifier {
  final _logger = Logger('PersonFormViewModel');
  final SavePersonUseCase _savePerson;

  bool isSaving = false;
  String? error;

  PersonFormViewModel(this._savePerson);

  Future<Person?> savePerson({
    String? name,
    required String givenName,
    required String familyName,
    required String jobTitle,
  }) async {
    _logger.info('Saving person ${name ?? "new"}');
    isSaving = true;
    error = null;
    notifyListeners();

    try {
      final personToSave = Person(
        name: name ?? '',
        givenName: givenName,
        familyName: familyName,
        jobTitle: jobTitle,
      );
      final saved = await _savePerson(personToSave);
      _logger.info('Successfully saved person ${saved.name}');
      return saved;
    } on ArgumentError catch (e) {
       _logger.warning('Validation failed: ${e.message}');
       error = e.message;
       return null;
    } catch (e, stackTrace) {
      _logger.severe('Failed to save person', e, stackTrace);
      error = e.toString();
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
