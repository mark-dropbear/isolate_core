import 'package:rdf_dart/rdf_dart.dart';
import '../../api/models/vocab.dart';
import '../../api/models/thing.dart';
import '../../transport/transport_client.dart';
import '../../transport/transport_models.dart';
import '../../api/models/api_requests.dart';
import 'package:logging/logging.dart';

class ThingApiService {
  final _logger = Logger('ThingApiService');
  final TransportClient _client;

  ThingApiService(this._client);

  Future<ListThingsResponse> listThings(ListThingsRequest request) async {
    _logger.info('listThings()');
    String path = '/things';
    final queryParams = <String>[];
    if (request.pageSize != null) {
      queryParams.add('pageSize=${request.pageSize}');
    }
    if (request.pageToken != null) {
      queryParams.add('pageToken=${request.pageToken}');
    }
    if (queryParams.isNotEmpty) {
      path += '?${queryParams.join('&')}';
    }

    final response = await _client.send(
      TransportRequest(method: 'GET', path: path),
    );

    if (response.statusCode == 200) {
      if (response.body == null || response.body is! String) {
        return const ListThingsResponse(things: []);
      }
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return ListThingsResponse.fromDataset(dataset);
    } else {
      _logger.warning('listThings failed: ${response.statusCode}');
      throw Exception('Failed to load things: ${response.statusCode}');
    }
  }

  Future<Thing> getThing(GetThingRequest request) async {
    _logger.info('getThing(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'GET', path: '/${request.name}'),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return Thing.fromDataset(dataset, request.name);
    } else {
      _logger.warning('getThing failed: ${response.statusCode}');
      throw Exception(
        'Failed to get thing ${request.name}: ${response.statusCode}',
      );
    }
  }

  Future<Thing> createThing(CreateThingRequest request) async {
    _logger.info('createThing()');
    String path = '/things';
    if (request.thingId != null && request.thingId!.isNotEmpty) {
      path += '?thingId=${request.thingId}';
    }

    final response = await _client.send(
      TransportRequest(
        method: 'POST',
        path: path,
        body: nQuadsCodec.encode(request.thing.toDataset()),
      ),
    );

    if (response.statusCode == 201) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      // We don't know the exact new ID here until we parse the dataset
      // The dataset returned will have the new IRI. We can just pick the first graph name.
      final graphNames = dataset.map((q) => q.graph).whereType<NamedNode>();
      final name = graphNames.isNotEmpty
          ? Vocab.getResourceName(graphNames.first)
          : '';
      return Thing.fromDataset(dataset, name);
    } else {
      _logger.warning('createThing failed: ${response.statusCode}');
      throw Exception('Failed to create thing: ${response.statusCode}');
    }
  }

  Future<Thing> updateThing(UpdateThingRequest request) async {
    _logger.info('updateThing(${request.thing.name})');

    String path = '/${request.thing.name}';
    if (request.updateMask != null && request.updateMask!.isNotEmpty) {
      path += '?updateMask=${request.updateMask!.join(',')}';
    }

    final response = await _client.send(
      TransportRequest(
        method: 'PATCH',
        path: path,
        body: nQuadsCodec.encode(request.thing.toDataset()),
      ),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return Thing.fromDataset(dataset, request.thing.name);
    } else {
      _logger.warning('updateThing failed: ${response.statusCode}');
      throw Exception('Failed to update thing: ${response.statusCode}');
    }
  }

  Future<void> deleteThing(DeleteThingRequest request) async {
    _logger.info('deleteThing(${request.name})');
    final response = await _client.send(
      TransportRequest(method: 'DELETE', path: '/${request.name}'),
    );

    if (response.statusCode != 204) {
      _logger.warning('deleteThing failed: ${response.statusCode}');
      throw Exception(
        'Failed to delete thing ${request.name}: ${response.statusCode}',
      );
    }
  }
}
