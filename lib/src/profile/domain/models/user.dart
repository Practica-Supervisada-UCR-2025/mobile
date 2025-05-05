class User {
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String? image;

  User({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'],
      lastName: json['lastName'],
      username: json['username'],
      email: json['email'],
      image: json['image'],
    );
  }
}