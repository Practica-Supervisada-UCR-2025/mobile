import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/auth/_children/login/presenter/widgets/login_form.dart';

/// Interface representing the login callback function.
abstract class LoginCallback {
  void call(String email, String password);
}

/// Manually created mock class for the LoginCallback interface.
class MockLoginCallback extends Mock implements LoginCallback {}

void main() {
  group('LoginForm Widget', () {
    late TextEditingController emailController;
    late TextEditingController passwordController;
    late MockLoginCallback mockLogin;

    setUp(() {
      emailController = TextEditingController();
      passwordController = TextEditingController();
      mockLogin = MockLoginCallback();
    });

    testWidgets('renders email and password fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              emailController: emailController,
              passwordController: passwordController,
              onLogin: mockLogin.call,
            ),
          ),
        ),
      );

      // Verify that there are two text form fields, one for email and one for password.
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    // testWidgets('does not call onLogin if form is invalid', (WidgetTester tester) async {
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: LoginForm(
    //           emailController: emailController,
    //           passwordController: passwordController,
    //           onLogin: mockLogin,
    //         ),
    //       ),
    //     ),
    //   );

    //   // Simulate tapping the login button without entering any data.
    //   await tester.tap(find.text('Login'));
    //   await tester.pump();

    //   // Assert that there are zero interactions on the mockLogin callback.
    //   verifyZeroInteractions(mockLogin);
    // });

    // testWidgets('calls onLogin if form is valid', (WidgetTester tester) async {
    //   await tester.pumpWidget(
    //     MaterialApp(
    //       home: Scaffold(
    //         body: LoginForm(
    //           emailController: emailController,
    //           passwordController: passwordController,
    //           onLogin: mockLogin,
    //         ),
    //       ),
    //     ),
    //   );

    //   // Fill in valid email and password fields.
    //   await tester.enterText(find.byType(TextFormField).at(0), 'user@ucr.ac.cr');
    //   await tester.enterText(find.byType(TextFormField).at(1), 'ValidPass1');

    //   // Simulate tapping the login button.
    //   await tester.tap(find.text('Login'));
    //   await tester.pump();

    //   // Verify that onLogin is called once with the correct parameters.
    //   verify(mockLogin.call('user@ucr.ac.cr', 'ValidPass1')).called(1);
    // });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoginForm(
              emailController: emailController,
              passwordController: passwordController,
              onLogin: mockLogin.call,
            ),
          ),
        ),
      );

      // Initially, the icon for hidden password should be present.
      final iconButton = find.byIcon(Icons.visibility_off);
      expect(iconButton, findsOneWidget);

      // Simulate tapping the icon to toggle password visibility.
      await tester.tap(iconButton);
      await tester.pump();

      // Verify that the icon now indicates the password is visible.
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });
}
