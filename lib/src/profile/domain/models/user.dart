class User {
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String image;

  User({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final fullName = data['full_name'] ?? '';
    final parts = fullName.split(' ');
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    final username = data['username'] ?? '';
    final email = data['email'] ?? '';
    final image = data['profile_picture'] ?? '';
    return User(
      username: username,
      email: email,
      image: image,
      firstName: firstName,
      lastName: lastName,
    );
  }
}
