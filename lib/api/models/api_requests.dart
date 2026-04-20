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

  factory ListThingsResponse.fromJson(Map<String, dynamic> json) {
    return ListThingsResponse(
      things: (json['things'] as List<dynamic>?)
              ?.map((e) => Thing.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nextPageToken: json['nextPageToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'things': things.map((e) => e.toJson()).toList(),
      if (nextPageToken != null) 'nextPageToken': nextPageToken,
    };
  }
}
