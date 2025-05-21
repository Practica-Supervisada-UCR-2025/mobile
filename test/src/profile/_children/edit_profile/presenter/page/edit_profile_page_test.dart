import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ProfileRepository, EditProfileRepository])
import 'edit_profile_page_test.mocks.dart';

void main() {
  late MockProfileRepository mockProfileRepository;
  late MockEditProfileRepository mockEditProfileRepository;
  late User testUser;
  late User updatedUser;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    mockEditProfileRepository = MockEditProfileRepository();
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider(
            create:
                (context) =>
                    ProfileBloc(profileRepository: mockProfileRepository),
          ),
          BlocProvider(
            create:
                (context) => EditProfileBloc(
                  editProfileRepository: mockEditProfileRepository,
                ),
          ),
        ],
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

      expect(firstNameField, findsOneWidget);
      expect(lastNameField, findsOneWidget);
      expect(usernameField, findsOneWidget);
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
      final editBloc = EditProfileBloc(
        editProfileRepository: mockEditProfileRepository,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: editBloc),
              BlocProvider(
                create:
                    (context) =>
                        ProfileBloc(profileRepository: mockProfileRepository),
              ),
            ],
            child: ProfileEditPage(user: testUser),
          ),
        ),
      );

      editBloc.emit(EditProfileFailure(error: 'Test error'));
      await tester.pump();

      expect(find.text('Update failed: Test error'), findsOneWidget);
    });

    testWidgets('should show loading indicator when saving', (
      WidgetTester tester,
    ) async {
      final editBloc = EditProfileBloc(
        editProfileRepository: mockEditProfileRepository,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: editBloc),
              BlocProvider(
                create:
                    (context) =>
                        ProfileBloc(profileRepository: mockProfileRepository),
              ),
            ],
            child: ProfileEditPage(user: testUser),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).first, 'Jane');
      await tester.pump();

      editBloc.emit(EditProfileUpdating());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show success snackbar and pop on update success', (
      WidgetTester tester,
    ) async {
      final editBloc = EditProfileBloc(
        editProfileRepository: mockEditProfileRepository,
      );
      final profileBloc = ProfileBloc(profileRepository: mockProfileRepository);

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
                (context, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: editBloc),
                    BlocProvider.value(value: profileBloc),
                  ],
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

      editBloc.emit(EditProfileSuccess(user: updatedUser));
      await tester.pump();

      await tester.pumpAndSettle();
      expect(find.text('Profile updated successfully'), findsOneWidget);
    });

    testWidgets('should call _saveChanges when save button is pressed', (
      WidgetTester tester,
    ) async {
      // Setup mock repository response
      when(
        mockEditProfileRepository.updateUserProfile(
          any,
          profilePicture: anyNamed('profilePicture'),
        ),
      ).thenAnswer((_) async => updatedUser);

      final editBloc = EditProfileBloc(
        editProfileRepository: mockEditProfileRepository,
      );
      final profileBloc = ProfileBloc(profileRepository: mockProfileRepository);

      // Create a mock navigation observer
      final mockObserver = MockNavigatorObserver();

      // Create router with two routes to simulate proper navigation stack
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder:
                (context, state) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => context.push('/edit'),
                      child: const Text('Navigate to Edit'),
                    ),
                  ),
                ),
          ),
          GoRoute(
            path: '/edit',
            builder:
                (context, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: editBloc),
                    BlocProvider.value(value: profileBloc),
                  ],
                  child: ProfileEditPage(user: testUser),
                ),
          ),
        ],
        observers: [mockObserver],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // First navigate to the edit page to establish a navigation stack
      await tester.tap(find.text('Navigate to Edit'));
      await tester.pumpAndSettle();

      // Make form dirty
      await tester.enterText(find.byType(TextField).first, 'Jane');
      await tester.pump();

      // edit userName
      await tester.enterText(find.byType(TextField).at(2), 'jane6');
      await tester.pump();

      // Tap save button
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pump();

      // Verify the repository method was called
      verify(
        mockEditProfileRepository.updateUserProfile(
          any,
          profilePicture: anyNamed('profilePicture'),
        ),
      ).called(1);

      // Verify the bloc state transitioned to success
      expect(editBloc.state, isA<EditProfileSuccess>());
    });

    testWidgets('should handle image selection and mark form as dirty', (
      WidgetTester tester,
    ) async {
      final editBloc = EditProfileBloc(
        editProfileRepository: mockEditProfileRepository,
      );
      final profileBloc = ProfileBloc(profileRepository: mockProfileRepository);
      final mockImageFile = File('test/test_assets/fake_image.jpg');

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider.value(value: editBloc),
              BlocProvider.value(value: profileBloc),
            ],
            child: ProfileEditPage(user: testUser),
          ),
        ),
      );

      // Verify initial state - save button should be disabled
      expect(
        tester
            .widget<TextButton>(find.byKey(const Key('save_button')))
            .onPressed,
        isNull,
      );

      // Find the ProfileImagePicker widget
      final imagePickerFinder = find.byType(ProfileImagePicker);
      expect(imagePickerFinder, findsOneWidget);

      // Get the widget instance and call the callback directly
      final imagePicker = tester.widget<ProfileImagePicker>(imagePickerFinder);
      imagePicker.onImageSelected(mockImageFile);
      await tester.pump();

      // Verify form is now dirty (save button enabled)
      expect(
        tester
            .widget<TextButton>(find.byKey(const Key('save_button')))
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('should include image in updates when saving', (
      WidgetTester tester,
    ) async {
      final mockImageFile = File('test/test_assets/fake_image.jpg');
      final editBloc = EditProfileBloc(
        editProfileRepository: mockEditProfileRepository,
      );
      final profileBloc = ProfileBloc(profileRepository: mockProfileRepository);
      final mockObserver = MockNavigatorObserver();

      // Setup mock to capture the profilePicture parameter
      when(
        mockEditProfileRepository.updateUserProfile(
          any,
          profilePicture: captureAnyNamed('profilePicture'),
        ),
      ).thenAnswer((_) async => updatedUser);

      // Create router with navigation stack
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder:
                (context, state) => Scaffold(
                  body: Center(
                    child: ElevatedButton(
                      onPressed: () => context.push('/edit'),
                      child: const Text('Navigate to Edit'),
                    ),
                  ),
                ),
          ),
          GoRoute(
            path: '/edit',
            builder:
                (context, state) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: editBloc),
                    BlocProvider.value(value: profileBloc),
                  ],
                  child: ProfileEditPage(user: testUser),
                ),
          ),
        ],
        observers: [mockObserver],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      // First navigate to the edit page to establish a navigation stack
      await tester.tap(find.text('Navigate to Edit'));
      await tester.pumpAndSettle();

      // Select an image
      final imagePicker = tester.widget<ProfileImagePicker>(
        find.byType(ProfileImagePicker),
      );
      imagePicker.onImageSelected(mockImageFile);
      await tester.pump();

      // Make another change to ensure form is dirty
      await tester.enterText(find.byType(TextField).first, 'Jane');
      await tester.pump();

      // Save the changes
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pump();

      // Verify the image was included in the update
      final captured =
          verify(
            mockEditProfileRepository.updateUserProfile(
              any,
              profilePicture: captureAnyNamed('profilePicture'),
            ),
          ).captured;

      expect(captured.last, equals(mockImageFile));
    });
  });
}

// Mock for the navigator observer
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
