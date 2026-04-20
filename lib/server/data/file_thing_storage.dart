import 'dart:convert';
import 'package:file/file.dart';
import '../../api/models/thing.dart';
import 'thing_storage.dart';

class FileThingStorage implements ThingStorage {
  final File _dataFile;

  FileThingStorage(this._dataFile) {
    if (!_dataFile.existsSync()) {
      _dataFile.writeAsStringSync('[]');
    }
  }

  List<dynamic> _readData() {
    final thingsJson = _dataFile.readAsStringSync();
    return jsonDecode(thingsJson) as List<dynamic>;
  }

  void _writeData(List<dynamic> things) {
    _dataFile.writeAsStringSync(jsonEncode(things));
  }

  @override
  Future<List<Thing>> getAllThings() async {
    final things = _readData();
    return things.map((json) => Thing.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<Thing?> getThingByName(String name) async {
    final things = _readData();
    final item = things.cast<Map<String, dynamic>>().firstWhere(
      (t) => t['name'] == name,
      orElse: () => <String, dynamic>{},
    );
    if (item.isEmpty) return null;
    return Thing.fromJson(item);
  }

  @override
  Future<Thing> createThing(Thing thing) async {
    final things = _readData();
    things.add(thing.toJson());
    _writeData(things);
    return thing;
  }

  @override
  Future<Thing> updateThing(Thing thing, {List<String>? updateMask}) async {
    final things = _readData();
    final index = things.indexWhere((t) => t['name'] == thing.name);
    
    if (index == -1) {
      throw Exception('Thing not found');
    }

    // Apply update mask
    if (updateMask == null || updateMask.isEmpty) {
      // Full replacement
      things[index] = thing.toJson();
    } else {
      // Partial update
      final currentThing = things[index] as Map<String, dynamic>;
      final newThingData = thing.toJson();
      
      for (final field in updateMask) {
        if (newThingData.containsKey(field)) {
          currentThing[field] = newThingData[field];
        }
      }
      things[index] = currentThing;
    }

    _writeData(things);
    return Thing.fromJson(things[index] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteThing(String name) async {
    final things = _readData();
    things.removeWhere((t) => t['name'] == name);
    _writeData(things);
  }
}
