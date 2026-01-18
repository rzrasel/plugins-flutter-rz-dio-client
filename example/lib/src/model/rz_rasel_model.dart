class RzRaselModel {
  final String userId;
  final String userName;

  RzRaselModel({
    required this.userId,
    required this.userName,
  });

  /// JSON → ENTITY
  factory RzRaselModel.fromJson(Map<String, dynamic> json) {
    return RzRaselModel(
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? '',
    );
  }

  /// ENTITY → JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
    };
  }
}