import 'package:rdf_dart/rdf_dart.dart';
import '../../transport/transport_client.dart';
import '../../transport/transport_models.dart';
import 'package:logging/logging.dart';

typedef FromDataset<T> = T Function(Dataset dataset, String name);
typedef ListFromDataset<T> = List<T> Function(Dataset dataset);
typedef ToDataset<T> = Dataset Function(T item);

class StandardResourceApiService<T> {
  final _logger = Logger('StandardResourceApiService');
  final TransportClient _client;
  final String _collectionPath;
  final FromDataset<T> _fromDataset;
  final ListFromDataset<T> _listFromDataset;
  final ToDataset<T> _toDataset;
  final String Function(T item) _getName;

  StandardResourceApiService({
    required TransportClient client,
    required String collectionPath,
    required FromDataset<T> fromDataset,
    required ListFromDataset<T> listFromDataset,
    required ToDataset<T> toDataset,
    required String Function(T item) getName,
  }) : _client = client,
       _collectionPath = collectionPath,
       _fromDataset = fromDataset,
       _listFromDataset = listFromDataset,
       _toDataset = toDataset,
       _getName = getName;

  Future<List<T>> listResources({int? pageSize, String? pageToken}) async {
    _logger.info('listResources($_collectionPath)');
    String path = '/$_collectionPath';
    final queryParams = <String>[];
    if (pageSize != null) {
      queryParams.add('pageSize=$pageSize');
    }
    if (pageToken != null) {
      queryParams.add('pageToken=$pageToken');
    }
    if (queryParams.isNotEmpty) {
      path += '?${queryParams.join('&')}';
    }

    final response = await _client.send(
      TransportRequest(method: 'GET', path: path),
    );

    if (response.statusCode == 200) {
      if (response.body == null || response.body is! String) {
        return [];
      }
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return _listFromDataset(dataset);
    } else {
      _logger.warning('listResources failed: ${response.statusCode}');
      throw Exception('Failed to load resources: ${response.statusCode}');
    }
  }

  Future<T> getResource(String name) async {
    _logger.info('getResource($name)');
    final response = await _client.send(
      TransportRequest(method: 'GET', path: '/$name'),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return _fromDataset(dataset, name);
    } else {
      _logger.warning('getResource failed: ${response.statusCode}');
      throw Exception('Failed to get resource $name: ${response.statusCode}');
    }
  }

  Future<T> createResource(T item, {String? resourceId}) async {
    _logger.info('createResource($_collectionPath)');
    String path = '/$_collectionPath';
    if (resourceId != null && resourceId.isNotEmpty) {
      path += '?resourceId=$resourceId';
    }

    final response = await _client.send(
      TransportRequest(
        method: 'POST',
        path: path,
        body: nQuadsCodec.encode(_toDataset(item)),
      ),
    );

    if (response.statusCode == 201) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      // Backend should return the new resource's dataset
      // We rely on fromDataset, but we don't know the generated ID easily unless we parse it
      // Let's assume listFromDataset handles parsing a single-item dataset, or we just extract the first graph.
      // For simplicity, we can use listFromDataset and take the first.
      final items = _listFromDataset(dataset);
      if (items.isNotEmpty) {
        return items.first;
      }
      throw Exception('Failed to parse created resource');
    } else {
      _logger.warning('createResource failed: ${response.statusCode}');
      throw Exception('Failed to create resource: ${response.statusCode}');
    }
  }

  Future<T> updateResource(T item, {List<String>? updateMask}) async {
    final name = _getName(item);
    _logger.info('updateResource($name)');

    String path = '/$name';
    if (updateMask != null && updateMask.isNotEmpty) {
      path += '?updateMask=${updateMask.join(",")}';
    }

    final response = await _client.send(
      TransportRequest(
        method: 'PATCH',
        path: path,
        body: nQuadsCodec.encode(_toDataset(item)),
      ),
    );

    if (response.statusCode == 200) {
      final dataset = MemoryDataset.fromIterable(
        nQuadsCodec.decode(response.body as String),
      );
      return _fromDataset(dataset, name);
    } else {
      _logger.warning('updateResource failed: ${response.statusCode}');
      throw Exception('Failed to update resource: ${response.statusCode}');
    }
  }

  Future<void> deleteResource(String name) async {
    _logger.info('deleteResource($name)');
    final response = await _client.send(
      TransportRequest(method: 'DELETE', path: '/$name'),
    );

    if (response.statusCode != 204) {
      _logger.warning('deleteResource failed: ${response.statusCode}');
      throw Exception(
        'Failed to delete resource $name: ${response.statusCode}',
      );
    }
  }
}
