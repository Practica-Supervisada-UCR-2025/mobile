class Paths {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  // ignore: constant_identifier_names
  static const String forgot_password = '/auth/forgot_password';
  static const String home = '/home';
  static const String search = '/search';
  static const String create = '/create';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static String externProfile(String userId) => '/profile/$userId';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String comments = '/comments';
}
