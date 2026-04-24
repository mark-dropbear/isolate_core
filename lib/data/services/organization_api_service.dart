import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/api_requests.dart';
import '../../api/models/organization.dart';
import '../../transport/transport_client.dart';
import '../../transport/transport_models.dart';
import 'package:logging/logging.dart';

class OrganizationApiService {
  final _logger = Logger('OrganizationApiService');
  final TransportClient _client;

  OrganizationApiService(this._client);

  Future<ListOrganizationsResponse> listOrganizations(ListOrganizationsRequest request) async {
    _logger.info('listOrganizations()');
    final response = await _client.send(
      const TransportRequest(method: 'GET', path: '/organizations'),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return ListOrganizationsResponse.fromDataset(dataset);
    } else {
      throw Exception('Failed to list organizations: ${response.statusCode}');
    }
  }

  Future<Organization> getOrganization(GetOrganizationRequest request) async {
    _logger.info('getOrganization(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'GET', path: '/${request.name}'),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return Organization.fromDataset(dataset, request.name);
    } else {
      throw Exception('Failed to get organization: ${response.statusCode}');
    }
  }

  Future<Organization> createOrganization(CreateOrganizationRequest request) async {
    _logger.info('createOrganization()');
    final response = await _client.send(
      TransportRequest(
        method: 'POST',
        path: '/organizations',
        body: nQuadsCodec.encode(request.organization.toDataset()),
      ),
    );

    if (response.statusCode == 201) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      final graphNameNode = dataset
          .map((q) => q.graph)
          .whereType<NamedNode>()
          .first;
      final apiPrefix = 'https://example.com/api/';
      final createdName = graphNameNode.value.substring(apiPrefix.length);
      return Organization.fromDataset(dataset, createdName);
    } else {
      throw Exception('Failed to create organization: ${response.statusCode}');
    }
  }

  Future<Organization> updateOrganization(UpdateOrganizationRequest request) async {
    _logger.info('updateOrganization(${request.organization.name})');
    final updateMaskParam = request.updateMask != null
        ? '?updateMask=${request.updateMask!.join(',')}'
        : '';
    final response = await _client.send(
      TransportRequest(
        method: 'PATCH',
        path: '/${request.organization.name}$updateMaskParam',
        body: nQuadsCodec.encode(request.organization.toDataset()),
      ),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return Organization.fromDataset(dataset, request.organization.name);
    } else {
      throw Exception('Failed to update organization: ${response.statusCode}');
    }
  }

  Future<void> deleteOrganization(DeleteOrganizationRequest request) async {
    _logger.info('deleteOrganization(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'DELETE', path: '/${request.name}'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete organization: ${response.statusCode}');
    }
  }
}
