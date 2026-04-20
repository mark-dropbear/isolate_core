import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/thing.dart';
import '../../domain/usecases/get_things_usecase.dart';
import '../../domain/usecases/delete_thing_usecase.dart';

class ThingListViewModel extends ChangeNotifier {
  final _logger = Logger('ThingListViewModel');
  final GetThingsUseCase _getThings;
  final DeleteThingUseCase _deleteThing;

  List<Thing> things = [];
  bool isLoading = false;
  String? error;

  ThingListViewModel(this._getThings, this._deleteThing);

  Future<void> loadThings() async {
    _logger.info('Loading things');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      things = await _getThings();
      _logger.info('Successfully loaded ${things.length} things');
    } catch (e, stackTrace) {
      _logger.severe('Failed to load things', e, stackTrace);
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteThing(String name) async {
    _logger.info('Deleting thing $name');
    try {
      await _deleteThing(name);
      things.removeWhere((t) => t.name == name);
      _logger.info('Successfully deleted thing $name');
      notifyListeners();
    } catch (e, stackTrace) {
      _logger.severe('Failed to delete thing $name', e, stackTrace);
      error = e.toString();
      notifyListeners();
    }
  }
}
