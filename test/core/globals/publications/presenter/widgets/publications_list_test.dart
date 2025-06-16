import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/storage/user_session.storage.dart';
import 'package:mobile/core/globals/publications/publications.dart';

// Mocks and fakes
class MockPublicationBloc extends MockBloc<PublicationEvent, PublicationState>
    implements PublicationBloc {}
class FakePublicationEvent extends Fake implements PublicationEvent {}
class FakePublicationState extends Fake implements PublicationState {}

void main() {
  const MethodChannel prefsChannel =
      MethodChannel('plugins.flutter.io/shared_preferences');
  late MockPublicationBloc mockBloc;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // ignore: deprecated_member_use
    prefsChannel.setMockMethodCallHandler((call) async {
      if (call.method == 'getAll') {
        return <String, Object>{'accessToken': 'token123'};
      }
      return null;
    });
    SharedPreferences.setMockInitialValues({'accessToken': 'token123'});
    await LocalStorage.init();
    registerFallbackValue(FakePublicationEvent());
    registerFallbackValue(FakePublicationState());
  });

  setUp(() {
    mockBloc = MockPublicationBloc();
  });

  tearDown(() {
    mockBloc.close();
  });

  Widget buildTestable(PublicationState state) {
    when(() => mockBloc.state).thenReturn(state);
    whenListen(mockBloc, Stream.value(state), initialState: state);

    return MaterialApp(
      home: BlocProvider<PublicationBloc>.value(
        value: mockBloc,
        child: const PublicationsList(scrollKey: 'testKey', isFeed: true),
      ),
    );
  }

  testWidgets('shows loading indicator', (tester) async {
    await mockNetworkImages(() async {
      await tester.pumpWidget(buildTestable(PublicationLoading()));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets('shows failure message and retry button', (tester) async {
    await mockNetworkImages(() async {
      await tester.pumpWidget(buildTestable(PublicationFailure()));
      await tester.pump();
      expect(find.text('Failed to load posts'), findsOneWidget);
      final retry = find.widgetWithText(ElevatedButton, 'Retry');
      expect(retry, findsOneWidget);
      await tester.tap(retry);
      verify(() => mockBloc.add(LoadPublications())).called(1);
    });
  });

  testWidgets('shows empty message when no publications', (tester) async {
    final emptyState = PublicationSuccess(
      publications: const [], totalPosts: 0, totalPages: 0, currentPage: 1);
    await mockNetworkImages(() async {
      await tester.pumpWidget(buildTestable(emptyState));
      await tester.pump();
      expect(find.text("You haven’t posted anything yet."), findsOneWidget);
    });
  });

  testWidgets('shows publications list on success', (tester) async {
    final pub = Publication(
      id: '1',
      username: 'u',
      profileImageUrl: 'url',
      content: 'c',
      createdAt: DateTime.now(),
      attachment: null,
      likes: 0,
      comments: 0,
    );
    final successState = PublicationSuccess(
      publications: [pub],
      totalPosts: 1,
      totalPages: 1,
      currentPage: 1,
    );
    await mockNetworkImages(() async {
      await tester.pumpWidget(buildTestable(successState));
      await tester.pumpAndSettle();
      expect(find.byType(PublicationCard), findsOneWidget);
    });
  });
}
