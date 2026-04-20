class TransportRequest {
  final String method;
  final String path;
  final String? body;
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
      body: json['body'] as String?,
      headers: (json['headers'] as Map<String, dynamic>?)?.cast<String, String>(),
    );
  }
}

class TransportResponse {
  final int statusCode;
  final String? body;

  const TransportResponse({
    required this.statusCode,
    this.body,
  });

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      if (body != null) 'body': body,
    };
  }

  factory TransportResponse.fromJson(Map<String, dynamic> json) {
    return TransportResponse(
      statusCode: json['statusCode'] as int,
      body: json['body'] as String?,
    );
  }
}
