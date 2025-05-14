import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mobile/src/profile/profile.dart';

class MockPublicationBloc extends Mock implements PublicationBloc {}
class FakePublicationEvent extends Fake implements PublicationEvent {}
class FakePublicationState extends Fake implements PublicationState {}

void main() {
  late MockPublicationBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakePublicationEvent());
    registerFallbackValue(FakePublicationState());
  });

  setUp(() {
    mockBloc = MockPublicationBloc();
  });

  Widget buildTestableWidget(PublicationState state) {
    when(() => mockBloc.state).thenReturn(state);
    whenListen(
      mockBloc,
      Stream<PublicationState>.fromIterable([state]),
      initialState: state,
    );
    return MaterialApp(
      home: BlocProvider<PublicationBloc>.value(
        value: mockBloc,
        child: const PublicationsList(),
      ),
    );
  }

  testWidgets('shows loading spinner when status is PublicationLoading',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationLoading();
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  testWidgets('displays error message and Retry button in PublicationFailure',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationFailure();
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));
      await tester.pump();
      verify(() => mockBloc.add(LoadPublications())).called(1);
    });
  });

  testWidgets('shows empty message when there are no publications',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationSuccess(publications: const [], hasReachedMax: false);
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.text("You haven’t posted anything yet."), findsOneWidget);
    });
  });

  testWidgets(
    'shows items + loading indicator when hasReachedMax is false',
    (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final pub = Publication(
          id: 1,
          username: 'user1',
          profileImageUrl: 'https://example.com/avatar.png',
          content: 'Hello World',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
          attachment: 'https://example.com/image.jpg',
          likes: 10,
          comments: 2,
        );
        final state = PublicationSuccess(publications: [pub], hasReachedMax: false);
        await tester.pumpWidget(buildTestableWidget(state));
        await tester.pump();

        expect(find.byType(PublicationCard), findsOneWidget);
        expect(
          find.byWidgetPredicate((w) =>
              w is Padding &&
              w.child is Center &&
              (w.child as Center).child is CircularProgressIndicator),
          findsOneWidget,
        );

        final listView = tester.widget<ListView>(find.byType(ListView));
        final controller = listView.controller!;
        await tester.pump(const Duration(milliseconds: 200)); // layout pass
        controller.jumpTo(controller.position.maxScrollExtent + 300);
        await tester.pump(const Duration(milliseconds: 200));

        verify(() => mockBloc.add(LoadMorePublications())).called(1);
      });
    },
  );

  testWidgets('displays “No more posts to show.” when hasReachedMax is true',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final pub = Publication(
        id: 2,
        username: 'user2',
        profileImageUrl: 'https://example.com/avatar2.png',
        content: 'Second post',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        attachment: null,
        likes: 5,
        comments: 1,
      );
      final state = PublicationSuccess(publications: [pub], hasReachedMax: true);
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.text('No more posts to show.'), findsOneWidget);
    });
  });

  testWidgets('renders empty SizedBox for unhandled states',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationInitial();
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}
