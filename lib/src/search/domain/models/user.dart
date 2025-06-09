class UserModel {
  final String username;
  final String userFullname;
  final String profilePicture;

  UserModel({
    required this.username,
    required this.userFullname,
    required this.profilePicture,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      userFullname: json['user_fullname'] ?? '',
      profilePicture: json['profile_picture'] ?? '',
    );
  }
}
