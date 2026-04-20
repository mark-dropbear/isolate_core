class TransportRequest {
  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final Map<String, String>? headers;

  const TransportRequest({
    required this.method,
    required this.path,
    this.body,
    this.headers,
  });

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'path': path,
      'body': body,
      'headers': headers,
    };
  }

  factory TransportRequest.fromJson(Map<String, dynamic> json) {
    return TransportRequest(
      method: json['method'] as String,
      path: json['path'] as String,
      body: json['body'] as Map<String, dynamic>?,
      headers: (json['headers'] as Map<String, dynamic>?)?.cast<String, String>(),
    );
  }
}

class TransportResponse {
  final int statusCode;
  final Map<String, dynamic>? body;
  final List<dynamic>? bodyList;

  const TransportResponse({
    required this.statusCode,
    this.body,
    this.bodyList,
  });

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      if (body != null) 'body': body,
      if (bodyList != null) 'bodyList': bodyList,
    };
  }

  factory TransportResponse.fromJson(Map<String, dynamic> json) {
    return TransportResponse(
      statusCode: json['statusCode'] as int,
      body: json['body'] as Map<String, dynamic>?,
      bodyList: json['bodyList'] as List<dynamic>?,
    );
  }
}
