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
    if (request.pageSize != null) queryParams.add('pageSize=${request.pageSize}');
    if (request.pageToken != null) queryParams.add('pageToken=${request.pageToken}');
    if (queryParams.isNotEmpty) {
      path += '?${queryParams.join('&')}';
    }

    final response = await _client.send(TransportRequest(
      method: 'GET',
      path: path,
    ));

    if (response.statusCode == 200) {
      return ListThingsResponse.fromJson(response.body ?? {'things': []});
    } else {
      _logger.warning('listThings failed: ${response.statusCode}');
      throw Exception('Failed to load things: ${response.statusCode}');
    }
  }

  Future<Thing> getThing(GetThingRequest request) async {
    _logger.info('getThing(${request.name})');
    final response = await _client.send(TransportRequest(
      method: 'GET',
      path: '/${request.name}',
    ));

    if (response.statusCode == 200) {
      return Thing.fromJson(response.body!);
    } else {
      _logger.warning('getThing failed: ${response.statusCode}');
      throw Exception('Failed to get thing ${request.name}: ${response.statusCode}');
    }
  }

  Future<Thing> createThing(CreateThingRequest request) async {
    _logger.info('createThing()');
    String path = '/things';
    if (request.thingId != null && request.thingId!.isNotEmpty) {
      path += '?thingId=${request.thingId}';
    }

    final response = await _client.send(TransportRequest(
      method: 'POST',
      path: path,
      body: request.thing.toJson(),
    ));

    if (response.statusCode == 201) {
      return Thing.fromJson(response.body!);
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

    final response = await _client.send(TransportRequest(
      method: 'PATCH',
      path: path,
      body: request.thing.toJson(),
    ));

    if (response.statusCode == 200) {
      return Thing.fromJson(response.body!);
    } else {
      _logger.warning('updateThing failed: ${response.statusCode}');
      throw Exception('Failed to update thing: ${response.statusCode}');
    }
  }

  Future<void> deleteThing(DeleteThingRequest request) async {
    _logger.info('deleteThing(${request.name})');
    final response = await _client.send(TransportRequest(
      method: 'DELETE',
      path: '/${request.name}',
    ));

    if (response.statusCode != 204) {
      _logger.warning('deleteThing failed: ${response.statusCode}');
      throw Exception('Failed to delete thing ${request.name}: ${response.statusCode}');
    }
  }
}
