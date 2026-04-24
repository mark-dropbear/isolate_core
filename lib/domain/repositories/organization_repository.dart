import '../../api/models/organization.dart';

abstract class OrganizationRepository {
  Future<List<Organization>> getOrganizations();
  Future<Organization> getOrganization(String name);
  Future<Organization> createOrganization(
      String displayName, OrganizationType type, String legalName, String description, String url);
  Future<Organization> updateOrganization(Organization organization);
  Future<void> deleteOrganization(String name);
}
