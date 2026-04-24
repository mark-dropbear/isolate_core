import '../../api/models/organization.dart';
import '../repositories/organization_repository.dart';

class GetOrganizationsUseCase {
  final OrganizationRepository _repository;

  GetOrganizationsUseCase(this._repository);

  Future<List<Organization>> call() {
    return _repository.getOrganizations();
  }
}
