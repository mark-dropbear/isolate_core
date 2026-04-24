import '../../api/models/organization.dart';
import '../repositories/organization_repository.dart';

class SaveOrganizationUseCase {
  final OrganizationRepository _repository;

  SaveOrganizationUseCase(this._repository);

  Future<Organization> call(Organization organization) async {
    if (organization.name.isEmpty) {
      return _repository.createOrganization(
        organization.displayName,
        organization.type,
        organization.legalName,
        organization.description,
        organization.url,
        employees: organization.employees,
      );
    } else {
      return _repository.updateOrganization(organization);
    }
  }
}
