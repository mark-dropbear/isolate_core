import '../../api/models/organization.dart';
import '../../domain/repositories/organization_repository.dart';
import '../../api/models/api_requests.dart';
import '../services/organization_api_service.dart';
import 'package:logging/logging.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  final _logger = Logger('OrganizationRepositoryImpl');
  final OrganizationApiService _apiService;

  OrganizationRepositoryImpl(this._apiService);

  @override
  Future<List<Organization>> getOrganizations() async {
    _logger.info('getOrganizations()');
    final response = await _apiService.listOrganizations(const ListOrganizationsRequest());
    return response.organizations;
  }

  @override
  Future<Organization> getOrganization(String name) async {
    _logger.info('getOrganization($name)');
    return _apiService.getOrganization(GetOrganizationRequest(name: name));
  }

  @override
  Future<Organization> createOrganization(
      String displayName, OrganizationType type, String legalName, String description, String url, {List<String> employees = const []}) async {
    _logger.info('createOrganization()');
    final organization = Organization(
      name: '',
      displayName: displayName,
      type: type,
      legalName: legalName,
      description: description,
      url: url,
      employees: employees,
    );
    return _apiService.createOrganization(CreateOrganizationRequest(organization: organization));
  }

  @override
  Future<Organization> updateOrganization(Organization organization) async {
    _logger.info('updateOrganization(${organization.name})');
    return _apiService.updateOrganization(
      UpdateOrganizationRequest(
        organization: organization,
        updateMask: ['name', 'type', 'legalName', 'description', 'url', 'employee'],
      ),
    );
  }

  @override
  Future<void> deleteOrganization(String name) async {
    _logger.info('deleteOrganization($name)');
    return _apiService.deleteOrganization(DeleteOrganizationRequest(name: name));
  }
}
