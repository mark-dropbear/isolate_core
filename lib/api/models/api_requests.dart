import 'package:rdf_dart/rdf_dart.dart';
import 'vocab.dart';
import 'thing.dart';

class GetThingRequest {
  final String name;
  const GetThingRequest({required this.name});
}

class CreateThingRequest {
  final Thing thing;
  final String? thingId;
  const CreateThingRequest({required this.thing, this.thingId});
}

class UpdateThingRequest {
  final Thing thing;
  final List<String>? updateMask;
  const UpdateThingRequest({required this.thing, this.updateMask});
}

class DeleteThingRequest {
  final String name;
  const DeleteThingRequest({required this.name});
}

class ListThingsRequest {
  final int? pageSize;
  final String? pageToken;
  const ListThingsRequest({this.pageSize, this.pageToken});
}

class ListThingsResponse {
  final List<Thing> things;
  final String? nextPageToken;

  const ListThingsResponse({required this.things, this.nextPageToken});

  factory ListThingsResponse.fromDataset(Dataset dataset) {
    final List<Thing> things = [];
    final graphNames = dataset
        .map((q) => q.graph)
        .whereType<NamedNode>()
        .toSet();

    for (final graphName in graphNames) {
      final resourceName = Vocab.getResourceName(graphName);
      things.add(Thing.fromDataset(dataset, resourceName));
    }

    return ListThingsResponse(things: things);
  }
}
