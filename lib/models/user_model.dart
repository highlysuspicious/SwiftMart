class UserModel {
  final String email;


  UserModel({
    required this.email,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
    );
  }

  UserModel copyWith({
    String? email,
  }) {
    return UserModel(
      email: email ?? this.email,
    );
  }
}