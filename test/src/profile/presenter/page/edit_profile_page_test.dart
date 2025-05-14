import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ProfileRepository])
import 'edit_profile_page_test.mocks.dart';

void main() {
  late MockProfileRepository mockProfileRepository;
  late User testUser;
  late User updatedUser;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    testUser = User(
      firstName: 'John',
      lastName: 'Doe',
      username: 'john6',
      email: 'john.doe@example.com',
      image: '',
    );

    updatedUser = User(
      firstName: 'Jane',
      lastName: 'Doe',
      username: 'jane6',
      email: 'jane.doe@example.com',
      image: '',
    );
  });

  Widget createProfileEditPage() {
    return MaterialApp(
      home: BlocProvider(
        create:
            (context) => ProfileBloc(profileRepository: mockProfileRepository),
        child: ProfileEditPage(user: testUser),
      ),
    );
  }

  group('ProfileEditPage', () {
    testWidgets('should render properly', (WidgetTester tester) async {
      await tester.pumpWidget(createProfileEditPage());
      expect(find.byType(ProfileEditPage), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Edit Profile'), findsOneWidget);
    });

    testWidgets('should initialize text fields with user data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createProfileEditPage());

      final firstNameField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == 'John',
      );

      final lastNameField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == 'Doe',
      );

      final usernameField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == 'john6',
      );

      final emailField = find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.controller?.text == 'john.doe@example.com',
      );

      expect(firstNameField, findsOneWidget);
      expect(lastNameField, findsOneWidget);
      expect(usernameField, findsOneWidget);
      expect(emailField, findsOneWidget);
    });

    testWidgets('should be able to edit text fields', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createProfileEditPage());

      final firstNameField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == 'John',
      );

      await tester.enterText(firstNameField, 'Jane');
      await tester.pump();

      final updatedField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == 'Jane',
      );

      expect(updatedField, findsOneWidget);
    });

    testWidgets('save button should be disabled when form is not dirty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createProfileEditPage());

      expect(
        tester.widget<TextButton>(find.byKey(Key('save_button'))).onPressed,
        isNull,
      );
    });

    testWidgets('should enable save button when form is dirty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createProfileEditPage());

      expect(
        tester.widget<TextButton>(find.byKey(Key('save_button'))).onPressed,
        isNull,
      );

      await tester.enterText(find.byType(TextField).first, 'Jane');
      await tester.pump();

      expect(
        tester.widget<TextButton>(find.byKey(Key('save_button'))).onPressed,
        isNotNull,
      );
    });

    testWidgets('should handle update failure', (WidgetTester tester) async {
      final bloc = ProfileBloc(profileRepository: mockProfileRepository);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ProfileEditPage(user: testUser),
          ),
        ),
      );

      bloc.emit(ProfileUpdateFailure(error: 'Test error', user: testUser));
      await tester.pump();

      expect(find.text('Update failed: Test error'), findsOneWidget);
    });

    testWidgets('should show loading indicator when saving', (
      WidgetTester tester,
    ) async {
      final bloc = ProfileBloc(profileRepository: mockProfileRepository);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: bloc,
            child: ProfileEditPage(user: testUser),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Jane');
      await tester.pump();

      bloc.emit(ProfileUpdating(user: testUser));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show success snackbar and pop on update success', (
      WidgetTester tester,
    ) async {
      final bloc = ProfileBloc(profileRepository: mockProfileRepository);

      late GoRouter router;

      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder:
                (context, state) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () {
                      context.push('/edit');
                    },
                    child: Text('Go to edit'),
                  ),
                ),
          ),
          GoRoute(
            path: '/edit',
            builder:
                (context, state) => BlocProvider.value(
                  value: bloc,
                  child: ProfileEditPage(user: testUser),
                ),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to edit'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Jane');
      await tester.pump();

      bloc.emit(ProfileUpdateSuccess(user: updatedUser));
      await tester.pump();

      await tester.pumpAndSettle();
      expect(find.text('Profile updated successfully'), findsOneWidget);
    });
  });
}

// Mock for the navigator observer
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
