import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/auth/_children/register/presenter/widgets/register_form.dart';

/// Interface representing the register callback function.
abstract class RegisterCallback {
  void call(String name, String email, String password);
}

/// Manually created mock class for the RegisterCallback interface.
class MockRegisterCallback extends Mock implements RegisterCallback {}

void main() {
  group('RegisterForm Widget', () {
    late TextEditingController nameController;
    late TextEditingController emailController;
    late TextEditingController passwordController;
    late TextEditingController confirmPasswordController;
    late MockRegisterCallback mockRegister;

    setUp(() {
      nameController = TextEditingController();
      emailController = TextEditingController();
      passwordController = TextEditingController();
      confirmPasswordController = TextEditingController();
      mockRegister = MockRegisterCallback();
    });

    testWidgets('renders all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterForm(
              nameController: nameController,
              emailController: emailController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              onRegister: mockRegister.call,
            ),
          ),
        ),
      );

      // Verify that there are four text form fields: name, email, password, and confirm password.
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('does not call onRegister if form is invalid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterForm(
              nameController: nameController,
              emailController: emailController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              onRegister: mockRegister.call,
            ),
          ),
        ),
      );

      // Simulate tapping the register button without entering any data.
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Assert that there are zero interactions on the mockRegister callback.
      verifyZeroInteractions(mockRegister);
    });

    testWidgets('calls onRegister if form is valid', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterForm(
              nameController: nameController,
              emailController: emailController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              onRegister: mockRegister.call,
            ),
          ),
        ),
      );

      // Fill in valid name, email, password, and confirm password fields.
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@ucr.ac.cr');
      await tester.enterText(find.byType(TextFormField).at(2), 'ValidPass1');
      await tester.enterText(find.byType(TextFormField).at(3), 'ValidPass1');

      // Simulate tapping the register button.
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Verify that onRegister is called once with the correct parameters.
      verify(mockRegister.call('Test User', 'user@ucr.ac.cr', 'ValidPass1')).called(1);
    });

    testWidgets('shows error if passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterForm(
              nameController: nameController,
              emailController: emailController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              onRegister: mockRegister.call,
            ),
          ),
        ),
      );

      // Fill in valid name, email, and password fields, but mismatched confirm password.
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@ucr.ac.cr');
      await tester.enterText(find.byType(TextFormField).at(2), 'ValidPass1');
      await tester.enterText(find.byType(TextFormField).at(3), 'InvalidPass');

      // Simulate tapping the register button.
      await tester.tap(find.text('Register'));
      await tester.pump();

      // Verify that an error message is displayed for mismatched passwords.
      expect(find.text('Passwords do not match'), findsOneWidget);

      // Assert that there are zero interactions on the mockRegister callback.
      verifyZeroInteractions(mockRegister);
    });

    testWidgets('toggles password visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RegisterForm(
              nameController: nameController,
              emailController: emailController,
              passwordController: passwordController,
              confirmPasswordController: confirmPasswordController,
              onRegister: mockRegister.call,
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
