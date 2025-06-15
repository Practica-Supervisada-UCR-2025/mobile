class UserModel {
  final String username;
  final String userFullname;
  final String profilePicture;
  final String id;

  UserModel({
    required this.username,
    required this.userFullname,
    required this.profilePicture,
    required this.id,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      userFullname: json['user_fullname'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
      id: json['id'] ?? '',
    );
  }
}
