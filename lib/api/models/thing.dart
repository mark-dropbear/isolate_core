class Thing {
  final String name;
  final String displayName;

  const Thing({
    required this.name,
    required this.displayName,
  });

  factory Thing.fromJson(Map<String, dynamic> json) {
    return Thing(
      name: json['name'] as String,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
    };
  }

  Thing copyWith({
    String? name,
    String? displayName,
  }) {
    return Thing(
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
    );
  }
}
