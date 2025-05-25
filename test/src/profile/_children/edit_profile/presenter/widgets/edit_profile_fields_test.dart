import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/profile/profile.dart';

void main() {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController usernameController;
  late GlobalKey<FormState> formKey;

  setUp(() {
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    usernameController = TextEditingController();
    formKey = GlobalKey<FormState>();
  });

  tearDown(() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
  });

  Future<void> pumpEditProfileFields(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            surface: Colors.white,
            onSurface: Colors.black,
            error: Colors.red,
            outline: Colors.grey,
          ),
        ),
        home: Scaffold(
          body: EditProfileFields(
            firstNameController: firstNameController,
            lastNameController: lastNameController,
            usernameController: usernameController,
            formKey: formKey,
          ),
        ),
      ),
    );
  }

  group('EditProfileFields Widget Tests', () {
    testWidgets('should render all text fields correctly', (
      WidgetTester tester,
    ) async {
      await pumpEditProfileFields(tester);

      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);

      expect(find.text('Enter your first name'), findsOneWidget);
      expect(find.text('Enter your last name'), findsOneWidget);
      expect(find.text('Enter your username'), findsOneWidget);

      expect(find.byIcon(Icons.person_outline), findsExactly(2));
    });

    testWidgets('should update controllers when text is entered', (
      WidgetTester tester,
    ) async {
      await pumpEditProfileFields(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'John');
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
      await tester.enterText(find.byType(TextFormField).at(2), 'johndoe');

      expect(firstNameController.text, 'John');
      expect(lastNameController.text, 'Doe');
      expect(usernameController.text, 'johndoe');
    });
  });
}
