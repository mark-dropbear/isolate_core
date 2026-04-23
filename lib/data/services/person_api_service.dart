import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/api_requests.dart';
import '../../api/models/person.dart';
import '../../transport/transport_client.dart';
import '../../transport/transport_models.dart';
import 'package:logging/logging.dart';

class PersonApiService {
  final _logger = Logger('PersonApiService');
  final TransportClient _client;

  PersonApiService(this._client);

  Future<ListPersonsResponse> listPersons(ListPersonsRequest request) async {
    _logger.info('listPersons()');
    final response = await _client.send(
      const TransportRequest(method: 'GET', path: '/persons'),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return ListPersonsResponse.fromDataset(dataset);
    } else {
      throw Exception('Failed to list persons: ${response.statusCode}');
    }
  }

  Future<Person> getPerson(GetPersonRequest request) async {
    _logger.info('getPerson(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'GET', path: '/${request.name}'),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return Person.fromDataset(dataset, request.name);
    } else {
      throw Exception('Failed to get person: ${response.statusCode}');
    }
  }

  Future<Person> createPerson(CreatePersonRequest request) async {
    _logger.info('createPerson()');
    final response = await _client.send(
      TransportRequest(
        method: 'POST',
        path: '/persons',
        body: nQuadsCodec.encode(request.person.toDataset()),
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
      return Person.fromDataset(dataset, createdName);
    } else {
      throw Exception('Failed to create person: ${response.statusCode}');
    }
  }

  Future<Person> updatePerson(UpdatePersonRequest request) async {
    _logger.info('updatePerson(${request.person.name})');
    final updateMaskParam = request.updateMask != null
        ? '?updateMask=${request.updateMask!.join(',')}'
        : '';
    final response = await _client.send(
      TransportRequest(
        method: 'PATCH',
        path: '/${request.person.name}$updateMaskParam',
        body: nQuadsCodec.encode(request.person.toDataset()),
      ),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return Person.fromDataset(dataset, request.person.name);
    } else {
      throw Exception('Failed to update person: ${response.statusCode}');
    }
  }

  Future<void> deletePerson(DeletePersonRequest request) async {
    _logger.info('deletePerson(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'DELETE', path: '/${request.name}'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete person: ${response.statusCode}');
    }
  }
}
