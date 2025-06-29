import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/storage/storage.dart';
import 'package:mobile/core/globals/publications/publications.dart'
    show
        LoadPublications,
        Publication,
        PublicationBloc,
        PublicationCard,
        PublicationEvent,
        PublicationFailure,
        PublicationInitial,
        PublicationLoading,
        PublicationState,
        PublicationSuccess,
        PublicationsList,
        PublicationsListState,
        RefreshPublications;

class MockPublicationBloc extends Mock implements PublicationBloc {}

class FakePublicationEvent extends Fake implements PublicationEvent {}

class FakePublicationState extends Fake implements PublicationState {}

void main() {
  late MockPublicationBloc mockBloc;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
    registerFallbackValue(FakePublicationEvent());
    registerFallbackValue(FakePublicationState());
  });

  setUp(() {
    mockBloc = MockPublicationBloc();
  });

  Widget buildTestableWidget(
    PublicationState state, {
    ScrollController? controller,
  }) {
    when(() => mockBloc.state).thenReturn(state);
    whenListen(
      mockBloc,
      Stream<PublicationState>.fromIterable([state]),
      initialState: state,
    );
    final scrollController = controller ?? ScrollController();

    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<PublicationBloc>.value(
          value: mockBloc,
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              PublicationsList(
                scrollKey: "ownPublications",
                isFeed: false,
                isOtherUser: false,
                scrollController: scrollController,
              ),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('shows loading spinner when status is PublicationLoading', (
    WidgetTester tester,
  ) async {
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
        verify(
          () =>
              mockBloc.add(LoadPublications(isFeed: false, isOtherUser: false)),
        ).called(1);
      });
    },
  );

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
    },
  );

  testWidgets('renders list of publications and loading indicator at end', (
    WidgetTester tester,
  ) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationSuccess(
        publications: [
          Publication(
            id: '1',
            content: 'test',
            userId: 'u1',
            username: 'user',
            profileImageUrl: 'https://example.com/avatar.jpg',
            createdAt: DateTime.now(),
            likes: 5,
            comments: 2,
          ),
        ],
        totalPosts: 1,
        totalPages: 1,
        currentPage: 1,
        hasReachedMax: false,
      );
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();

      expect(find.byType(PublicationCard), findsOneWidget);
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      ); // load more
    });
  });

  testWidgets('renders "no more posts" text when hasReachedMax is true', (
    WidgetTester tester,
  ) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationSuccess(
        publications: [
          Publication(
            id: '1',
            content: 'test',
            userId: 'u1',
            username: 'user',
            profileImageUrl: 'https://example.com/avatar.jpg',
            createdAt: DateTime.now(),
            likes: 5,
            comments: 2,
          ),
        ],
        totalPosts: 1,
        totalPages: 1,
        currentPage: 1,
        hasReachedMax: true,
      );
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();

      expect(find.text('No more posts to show.'), findsOneWidget);
    });
  });

  testWidgets('renders fallback widget for unhandled state', (
    WidgetTester tester,
  ) async {
    await mockNetworkImagesFor(() async {
      final state = PublicationInitial();
      await tester.pumpWidget(buildTestableWidget(state));
      await tester.pump();
      expect(find.textContaining('Failed to load'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(PublicationCard), findsNothing);
      expect(find.byType(SliverList), findsNothing);
    });
  });

  testWidgets(
    'refresh() triggers RefreshPublications and scrolls to top (without waiting)',
    (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final scrollController = ScrollController(initialScrollOffset: 150);

        final state = PublicationSuccess(
          publications: [],
          totalPosts: 0,
          totalPages: 1,
          currentPage: 1,
        );

        when(() => mockBloc.state).thenReturn(state);
        when(() => mockBloc.stream).thenAnswer(
          (_) => Stream.value(
            PublicationSuccess(
              publications: [],
              totalPosts: 0,
              totalPages: 1,
              currentPage: 1,
            ),
          ),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BlocProvider<PublicationBloc>.value(
                value: mockBloc,
                child: SizedBox.expand(
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      PublicationsList(
                        scrollKey: "testKey",
                        isFeed: false,
                        isOtherUser: false,
                        scrollController: scrollController,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final stateFinder = find.byType(PublicationsList);
        expect(stateFinder, findsOneWidget);

        final listState = tester.state<PublicationsListState>(stateFinder);

        await listState.refresh();

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        verify(
          () => mockBloc.add(
            RefreshPublications(isFeed: false, isOtherUser: false),
          ),
        ).called(1);

        expect(scrollController.offset, 0.0);
      });
    },
  );
}
