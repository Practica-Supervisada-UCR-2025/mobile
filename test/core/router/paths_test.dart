import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/router/paths.dart';

void main() {
  test('Paths constants are correctly defined', () {
    expect(Paths.login, '/auth/login');
    expect(Paths.register, '/auth/register');
    expect(Paths.forgot_password, '/auth/forgot_password');
    expect(Paths.home, '/home');
    expect(Paths.search, '/search');
    expect(Paths.create, '/create');
    expect(Paths.notifications, '/notifications');
    expect(Paths.profile, '/profile');
    expect(Paths.settings, '/settings');
  });
}
