import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/organization.dart';
import '../../domain/usecases/get_organizations_usecase.dart';
import '../../domain/usecases/delete_organization_usecase.dart';

class OrganizationListViewModel extends ChangeNotifier {
  final _logger = Logger('OrganizationListViewModel');
  final GetOrganizationsUseCase _getOrganizations;
  final DeleteOrganizationUseCase _deleteOrganization;

  List<Organization> organizations = [];
  bool isLoading = false;
  String? error;

  OrganizationListViewModel(this._getOrganizations, this._deleteOrganization);

  Future<void> loadOrganizations() async {
    _logger.info('Loading organizations');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      organizations = await _getOrganizations();
      _logger.info('Successfully loaded ${organizations.length} organizations');
    } catch (e, stackTrace) {
      _logger.severe('Failed to load organizations', e, stackTrace);
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteOrganization(String name) async {
    _logger.info('Deleting organization $name');
    try {
      await _deleteOrganization(name);
      organizations.removeWhere((o) => o.name == name);
      _logger.info('Successfully deleted organization $name');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Failed to delete organization $name', e, stackTrace);
      error = e.toString();
      notifyListeners();
    }
  }
}
