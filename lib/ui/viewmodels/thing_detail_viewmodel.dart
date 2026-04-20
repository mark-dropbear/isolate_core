import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/thing.dart';
import '../../domain/usecases/save_thing_usecase.dart';

class ThingDetailViewModel extends ChangeNotifier {
  final _logger = Logger('ThingDetailViewModel');
  final SaveThingUseCase _saveThing;
  
  bool isLoading = false;
  String? error;

  ThingDetailViewModel(this._saveThing);

  Future<bool> saveThing(Thing? existingThing, String displayName) async {
    _logger.info('Saving thing: ${existingThing?.name ?? "new"}');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _saveThing(existingThing, displayName);
      _logger.info('Successfully saved thing');
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Failed to save thing', e, stackTrace);
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
