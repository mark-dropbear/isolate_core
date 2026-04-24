import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/organization.dart';
import '../../domain/usecases/save_organization_usecase.dart';

class OrganizationFormViewModel extends ChangeNotifier {
  final _logger = Logger('OrganizationFormViewModel');
  final SaveOrganizationUseCase _saveOrganization;

  bool isSaving = false;
  String? error;

  OrganizationFormViewModel(this._saveOrganization);

  Future<Organization?> saveOrganization({
    String? name,
    required String displayName,
    required OrganizationType type,
    required String legalName,
    required String description,
    required String url,
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
