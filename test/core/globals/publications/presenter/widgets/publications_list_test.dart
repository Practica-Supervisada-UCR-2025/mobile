import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile/core/globals/publications/publications.dart'
    show
        PublicationBloc,
        PublicationEvent,
        PublicationState,
        LoadPublications,
        LoadMorePublications,
        PublicationInitial,
        PublicationLoading,
        PublicationFailure,
        PublicationSuccess,
        Publication,
        PublicationsList,
        PublicationCard;

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
        child: const PublicationsList(scrollKey: "ownPublications"),
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

  testWidgets(
      'shows error message and Retry button when status is PublicationFailure',
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

  testWidgets(
      'shows empty message when PublicationSuccess contains empty list',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationSuccess(
        publications: const [],
        totalPosts: 0,
        totalPages: 1,
        currentPage: 1,
      );
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();

      expect(find.text("You haven’t posted anything yet."), findsOneWidget);
    });
  });

  testWidgets(
      'renders items and loading spinner at the end when hasReachedMax is false',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final pub = Publication(
        id: 1,
        username: 'user1',
        profileImageUrl: 'https://example.com/avatar.png',
        content: 'Hello World',
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      final state = PublicationSuccess(
        publications: [pub],
        totalPosts: 2,
        totalPages: 2,
        currentPage: 1,
      );
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
      await tester.pump();
      controller.jumpTo(controller.position.maxScrollExtent + 300);
      await tester.pump(const Duration(milliseconds: 200));

      verify(() => mockBloc.add(LoadMorePublications())).called(1);
    });
  });

  testWidgets(
      'shows "No more posts to show." when hasReachedMax is true',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final pub = Publication(
        id: 2,
        username: 'user2',
        profileImageUrl: 'https://example.com/avatar2.png',
        content: 'Second post',
        createdAt: DateTime.now(),
        attachment: null,
        likes: 0,
        comments: 0,
      );
      final state = PublicationSuccess(
        publications: [pub],
        totalPosts: 1,
        totalPages: 1,
        currentPage: 1,
      );
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();

      expect(find.text('No more posts to show.'), findsOneWidget);
    });
  });

  testWidgets('renders SizedBox.shrink() for unhandled states',
      (WidgetTester tester) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationInitial();
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.byType(SizedBox), findsOneWidget);
    });
  });
}