import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import '../../api/models/thing.dart';
import '../../core/di/injection_container.dart';
import '../../domain/usecases/standard_usecases.dart';

class ThingDetailViewModel extends ChangeNotifier {
  final _logger = Logger('ThingDetailViewModel');
  final SaveResourceUseCase<Thing> _saveThing;

  bool isLoading = false;
  String? error;

  ThingDetailViewModel({SaveResourceUseCase<Thing>? saveThing})
    : _saveThing = saveThing ?? getIt<SaveResourceUseCase<Thing>>();

  Future<bool> saveThing(Thing? existingThing, String displayName) async {
    _logger.info('Saving thing: ${existingThing?.name ?? "new"}');
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final updatedThing = Thing(
        name: existingThing?.name ?? '',
        displayName: displayName,
      );
      await _saveThing.execute(updatedThing, isCreate: existingThing == null);
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
