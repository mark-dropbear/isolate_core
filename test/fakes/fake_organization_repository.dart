import 'package:isolate_core/api/models/organization.dart';
import 'package:isolate_core/api/models/resource_name.dart';
import 'package:isolate_core/domain/repositories/organization_repository.dart';

class FakeOrganizationRepository implements OrganizationRepository {
  final List<Organization> _organizations = [];

  void seed(List<Organization> initialOrganizations) {
    _organizations.clear();
    _organizations.addAll(initialOrganizations);
  }

  @override
  Future<List<Organization>> getOrganizations() async {
    return List.from(_organizations);
  }

  @override
  Future<Organization> getOrganization(String name) async {
    return _organizations.firstWhere(
      (o) => o.name == name,
      orElse: () => throw Exception('Organization not found'),
    );
  }

  @override
  Future<Organization> createOrganization(
      String displayName, OrganizationType type, String legalName, String description, String url, {List<String> employees = const []}) async {
    final newOrganization = Organization(
      name: ResourceName.generate('organizations').toString(),
      displayName: displayName,
      type: type,
      legalName: legalName,
      description: description,
      url: url,
      employees: employees,
    );
    _organizations.add(newOrganization);
    return newOrganization;
  }

  @override
  Future<Organization> updateOrganization(Organization organization) async {
    final index = _organizations.indexWhere((o) => o.name == organization.name);
    if (index == -1) {
      throw Exception('Organization not found');
    }
    _organizations[index] = organization;
    return organization;
  }

  @override
  Future<void> deleteOrganization(String name) async {
    _organizations.removeWhere((o) => o.name == name);
  }
}
