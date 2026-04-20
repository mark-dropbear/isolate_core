import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/thing.dart';
import '../../core/di/injection_container.dart';
import '../../domain/usecases/standard_usecases.dart';

class ThingListViewModel extends ChangeNotifier {
  final _logger = Logger('ThingListViewModel');
  final ListResourcesUseCase<Thing> _getThings;
  final DeleteResourceUseCase<Thing> _deleteThing;

  List<Thing> things = [];
  bool isLoading = false;
  String? error;

  ThingListViewModel({
    ListResourcesUseCase<Thing>? getThings,
    DeleteResourceUseCase<Thing>? deleteThing,
  }) : _getThings = getThings ?? getIt<ListResourcesUseCase<Thing>>(),
       _deleteThing = deleteThing ?? getIt<DeleteResourceUseCase<Thing>>();

  Future<void> loadThings() async {
    _logger.info('Loading things');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      things = await _getThings.execute();
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
      await _deleteThing.execute(name);
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
