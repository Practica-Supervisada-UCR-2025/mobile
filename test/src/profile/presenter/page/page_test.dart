import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/src/profile/domain/models/models.dart';
import 'package:mobile/src/profile/presenter/bloc/profile_bloc.dart';
import 'package:mobile/src/profile/presenter/page/page.dart';
import 'package:mobile/core/globals/widgets/secondary_button.dart';
import 'package:network_image_mock/network_image_mock.dart';

final testUser = User(
  firstName: 'John',
  lastName: 'Doe',
  username: 'johndoe',
  email: 'user@ucr.ac.cr.com',
  image: 'https://dummyjson.com/icon/emilys/128',
);

class MockProfileBloc extends MockBloc<ProfileEvent, ProfileState>
    implements ProfileBloc {}

void main() {
  late MockProfileBloc mockProfileBloc;

  setUp(() {
    mockProfileBloc = MockProfileBloc();
  });

  tearDown(() {
    mockProfileBloc.close();
  });

  Widget buildTestableWidget() {
    return MaterialApp(
      home: BlocProvider<ProfileBloc>.value(
        value: mockProfileBloc,
        child: const ProfileScreen(),
      ),
    );
  }

  group('ProfileScreen', () {
    testWidgets('shows loading indicator when state is ProfileLoading',
        (WidgetTester tester) async {
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([ProfileLoading()]),
        initialState: ProfileLoading(),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows user data when state is ProfileSuccess',
        (WidgetTester tester) async {
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
        expect(find.byType(SecondaryButton), findsNWidgets(2));
      });
    });

    testWidgets('shows error message when state is ProfileFailure',
        (WidgetTester tester) async {
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([ProfileFailure(error: 'Error  profile')]),
        initialState: ProfileFailure(error: 'Error loading profile'),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Error loading profile'), findsOneWidget);
    });

    testWidgets('shows placeholder when state is unknown',
        (WidgetTester tester) async {
      whenListen(
        mockProfileBloc,
        Stream.fromIterable([ProfileInitial()]),
        initialState: ProfileInitial(),
      );

      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
