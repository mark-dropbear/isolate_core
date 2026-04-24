import '../repositories/organization_repository.dart';

class DeleteOrganizationUseCase {
  final OrganizationRepository _repository;

  DeleteOrganizationUseCase(this._repository);

  Future<void> call(String name) {
    return _repository.deleteOrganization(name);
  }
}
