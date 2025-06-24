import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:mobile/core/core.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

final testUser = User(
  firstName: 'John',
  lastName: 'Doe',
  username: 'johndoe',
  email: 'user@ucr.ac.cr.com',
  image: 'https://dummyjson.com/icon/emilys/128',
);

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

class MockPublicationBloc extends MockBloc<PublicationEvent, PublicationState>
    implements PublicationBloc {}

class MockPublicationRepository extends Mock implements PublicationRepository {}

void main() {
  late MockProfileBloc mockProfileBloc;
  late MockPublicationBloc mockPublicationBloc;
  late MockPublicationRepository mockPublicationRepository;

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    mockPublicationBloc = MockPublicationBloc();
    mockPublicationRepository = MockPublicationRepository();

    when(() => mockPublicationBloc.state).thenReturn(PublicationInitial());
    whenListen(mockPublicationBloc, Stream<PublicationState>.empty());
  });

  tearDown(() {
    mockProfileBloc.close();
    mockPublicationBloc.close();
  });

  Widget buildTestableWidget() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Provider<PublicationRepository>.value(
            value: mockPublicationRepository,
            child: MultiProvider(
              providers: [
                BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
                BlocProvider<PublicationBloc>.value(value: mockPublicationBloc),
              ],
              child: const ProfileScreen(isFeed: false),
            ),
          ),
        ),
        GoRoute(
          path: Paths.editProfile,
          builder: (context, state) {
            final user = state.extra as User;
            return Scaffold(
              appBar: AppBar(title: const Text('Edit Profile')),
              body: Text('Editing ${user.username}'),
            );
          },
        ),
      ],
    );

    return MaterialApp.router(routerConfig: router);
  }

  group('ProfileScreen', () {
    testWidgets(
      'shows profile skeleton indicator when state is ProfileLoading',
      (WidgetTester tester) async {
        whenListen(
          mockProfileBloc,
          Stream.fromIterable([ProfileLoading()]),
          initialState: ProfileLoading(),
        );

        await tester.pumpWidget(buildTestableWidget());

        expect(find.byType(ProfileSkeleton), findsOneWidget);
      },
    );

    testWidgets('shows user data when state is ProfileSuccess', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([ProfileSuccess(user: testUser)]),
        initialState: ProfileSuccess(user: testUser),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(buildTestableWidget());

        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('@johndoe'), findsOneWidget);
        expect(find.text('user@ucr.ac.cr.com'), findsOneWidget);
        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byType(SecondaryButton), findsNWidgets(1));
      });
    });

    testWidgets('shows error message when state is ProfileFailure', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([ProfileFailure(error: 'Error profile')]),
        initialState: ProfileFailure(error: 'Error loading profile'),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Error loading profile'), findsOneWidget);
    });

    testWidgets('shows placeholder when state is unknown', (
      WidgetTester tester,
    ) async {
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([ProfileInitial()]),
        initialState: ProfileInitial(),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('navigates to edit profile page on button tap', (
      WidgetTester tester,
      ) async {
        whenListen(
          mockProfileBloc,
          Stream.fromIterable([ProfileSuccess(user: testUser)]),
          initialState: ProfileSuccess(user: testUser),
        );

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(buildTestableWidget());

          final editButton = find.text('Edit Profile');
          expect(editButton, findsOneWidget);

          await tester.tap(editButton);
          await tester.pumpAndSettle();

          expect(find.text('Edit Profile'), findsOneWidget);
        });
      });
  });
}
