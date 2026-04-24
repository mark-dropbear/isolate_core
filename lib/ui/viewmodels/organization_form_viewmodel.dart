import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/organization.dart';
import '../../api/models/person.dart';
import '../../domain/usecases/save_organization_usecase.dart';
import '../../domain/usecases/get_persons_usecase.dart';

class OrganizationFormViewModel extends ChangeNotifier {
  final _logger = Logger('OrganizationFormViewModel');
  final SaveOrganizationUseCase _saveOrganization;
  final GetPersonsUseCase _getPersons;

  bool isSaving = false;
  String? error;

  List<Person> availablePersons = [];

  OrganizationFormViewModel(this._saveOrganization, this._getPersons);

  Future<void> loadAvailablePersons() async {
    _logger.info('Loading available persons for organization form');
    try {
      availablePersons = await _getPersons();
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Failed to load persons', e, stackTrace);
    }
  }

  Future<Organization?> saveOrganization({
    String? name,
    required String displayName,
    required OrganizationType type,
    required String legalName,
    required String description,
    required String url,
    List<String> employees = const [],
  }) async {
    _logger.info('Saving organization ${name ?? "new"}');
    isSaving = true;
    error = null;
    notifyListeners();

    try {
      final organizationToSave = Organization(
        name: name ?? '',
        displayName: displayName,
        type: type,
        legalName: legalName,
        description: description,
        url: url,
        employees: employees,
      );
      final saved = await _saveOrganization(organizationToSave);
      _logger.info('Successfully saved organization ${saved.name}');
      return saved;
    } on ArgumentError catch (e) {
       _logger.warning('Validation failed: ${e.message}');
       error = e.message;
       return null;
    } catch (e, stackTrace) {
      _logger.severe('Failed to save organization', e, stackTrace);
      error = e.toString();
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
