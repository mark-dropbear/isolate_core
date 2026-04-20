import '../../api/models/thing.dart';
import '../../domain/repositories/thing_repository.dart';
import '../../api/models/api_requests.dart';
import '../services/thing_api_service.dart';
import 'package:logging/logging.dart';

class ThingRepositoryImpl implements ThingRepository {
  final _logger = Logger('ThingRepositoryImpl');
  final ThingApiService _apiService;

  ThingRepositoryImpl(this._apiService);

  @override
  Future<List<Thing>> getThings() async {
    _logger.info('getThings()');
    final response = await _apiService.listThings(const ListThingsRequest());
    return response.things;
  }

  @override
  Future<Thing> getThing(String name) async {
    _logger.info('getThing($name)');
    return _apiService.getThing(GetThingRequest(name: name));
  }

  @override
  Future<Thing> createThing(String displayName) async {
    _logger.info('createThing($displayName)');
    final thing = Thing(name: '', displayName: displayName);
    return _apiService.createThing(CreateThingRequest(thing: thing));
  }

  @override
  Future<Thing> updateThing(Thing thing) async {
    _logger.info('updateThing(${thing.name})');
    return _apiService.updateThing(
      UpdateThingRequest(thing: thing, updateMask: ['displayName']),
    );
  }

  @override
  Future<void> deleteThing(String name) async {
    _logger.info('deleteThing($name)');
    return _apiService.deleteThing(DeleteThingRequest(name: name));
  }
}
