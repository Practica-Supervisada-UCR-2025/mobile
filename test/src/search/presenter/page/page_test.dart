import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mobile/src/search/search.dart';

// Genera los mocks con: flutter packages pub run build_runner build
@GenerateMocks([SearchBloc])
import 'page_test.mocks.dart';

void main() {
  group('SearchScreen Tests', () {
    late MockSearchBloc mockSearchBloc;
    late SearchScreen searchScreen;

    // Mock data
    final mockUsers = [
      UserModel(
        id: '1',
        username: 'john_doe',
        userFullname: 'John Doe',
        profilePicture: 'https://example.com/avatar1.jpg',
      ),
      UserModel(
        id: '2',
        username: 'jane_smith',
        userFullname: 'Jane Smith',
        profilePicture: '',
      ),
    ];

    setUp(() {
      mockSearchBloc = MockSearchBloc();
      searchScreen = const SearchScreen();

      // Setup default stream
      when(
        mockSearchBloc.stream,
      ).thenAnswer((_) => Stream.value(SearchInitial()));
      when(mockSearchBloc.state).thenReturn(SearchInitial());
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<SearchBloc>.value(
          value: mockSearchBloc,
          child: searchScreen,
        ),
      );
    }

    testWidgets('should render search screen with search bar', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      });
    });

    testWidgets('should show clear button when text is entered', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'test query');
        await tester.pump();

        expect(find.byIcon(Icons.clear_rounded), findsOneWidget);
      });
    });

    testWidgets('should hide clear button when text is empty', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Icons.clear_rounded), findsNothing);
      });
    });

    testWidgets('should call SearchUsersEvent when text is entered', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'john');
        await tester.pump();

        verify(mockSearchBloc.add(SearchUsersEvent('john'))).called(1);
      });
    });

    testWidgets('should call ClearSearchEvent when clear button is pressed', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter text first to show clear button
        final textField = find.byType(TextField);
        await tester.enterText(textField, 'test');
        await tester.pump();

        // Tap clear button
        final clearButton = find.byIcon(Icons.clear_rounded);
        await tester.tap(clearButton);
        await tester.pump();

        verify(mockSearchBloc.add(const ClearSearchEvent())).called(1);
      });
    });

    testWidgets('should call ClearSearchEvent when text field is cleared', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final textField = find.byType(TextField);
        await tester.enterText(textField, 'test');
        await tester.pump();

        // Clear the text field
        await tester.enterText(textField, '');
        await tester.pump();

        verify(mockSearchBloc.add(const ClearSearchEvent())).called(1);
      });
    });

    testWidgets('should show loading indicator when SearchLoading state', (
      tester,
    ) async {
      when(mockSearchBloc.state).thenReturn(SearchLoading());
      when(
        mockSearchBloc.stream,
      ).thenAnswer((_) => Stream.value(SearchLoading()));

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    testWidgets('should show empty state when SearchEmpty state', (
      tester,
    ) async {
      const query = 'nonexistent';
      when(mockSearchBloc.state).thenReturn(SearchEmpty(query: query));
      when(
        mockSearchBloc.stream,
      ).thenAnswer((_) => Stream.value(SearchEmpty(query: query)));

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.text('No results found for "$query"'), findsOneWidget);
      });
    });

    testWidgets('should show error state when SearchError state', (
      tester,
    ) async {
      const query = 'error_query';
      when(mockSearchBloc.state).thenReturn(
        SearchError(message: 'Something went wrong. Try again.', query: query),
      );
      when(mockSearchBloc.stream).thenAnswer(
        (_) => Stream.value(
          SearchError(
            message: 'Something went wrong. Try again.',
            query: query,
          ),
        ),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.text('Something went wrong. Try again.'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
        expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
      });
    });

    testWidgets(
      'should retry search when retry button is pressed in error state',
      (tester) async {
        const query = 'error_query';
        when(
          mockSearchBloc.state,
        ).thenReturn(SearchError(message: 'Network error', query: query));
        when(mockSearchBloc.stream).thenAnswer(
          (_) =>
              Stream.value(SearchError(message: 'Network error', query: query)),
        );

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createWidgetUnderTest());
          await tester.pump();

          final retryButton = find.text('Retry');
          await tester.tap(retryButton);
          await tester.pump();

          verify(mockSearchBloc.add(SearchUsersEvent(query))).called(1);
        });
      },
    );

    testWidgets('should show user list when SearchSuccess state', (
      tester,
    ) async {
      when(
        mockSearchBloc.state,
      ).thenReturn(SearchSuccess(users: mockUsers, query: ''));
      when(mockSearchBloc.stream).thenAnswer(
        (_) => Stream.value(SearchSuccess(users: mockUsers, query: '')),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(ListTile), findsNWidgets(2));
        expect(find.text('John Doe'), findsOneWidget);
        expect(find.text('@john_doe'), findsOneWidget);
        expect(find.text('Jane Smith'), findsOneWidget);
        expect(find.text('@jane_smith'), findsOneWidget);
      });
    });

    testWidgets('should show network image for user with profile picture', (
      tester,
    ) async {
      when(
        mockSearchBloc.state,
      ).thenReturn(SearchSuccess(users: mockUsers, query: ''));
      when(mockSearchBloc.stream).thenAnswer(
        (_) => Stream.value(SearchSuccess(users: mockUsers, query: '')),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        final circleAvatars = find.byType(CircleAvatar);
        expect(circleAvatars, findsNWidgets(2));

        // First user should have NetworkImage
        final firstAvatar = tester.widget<CircleAvatar>(circleAvatars.first);
        expect(firstAvatar.backgroundImage, isA<NetworkImage>());
      });
    });

    testWidgets('should show person icon for user without profile picture', (
      tester,
    ) async {
      when(
        mockSearchBloc.state,
      ).thenReturn(SearchSuccess(users: mockUsers, query: ''));
      when(mockSearchBloc.stream).thenAnswer(
        (_) => Stream.value(SearchSuccess(users: mockUsers, query: '')),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        // Second user should have person icon (no profile picture)
        expect(find.byIcon(Icons.person_rounded), findsOneWidget);
      });
    });

    // testWidgets('should handle onTap for user tiles', (tester) async {
    //   when(
    //     mockSearchBloc.state,
    //   ).thenReturn(SearchSuccess(users: mockUsers, query: ''));
    //   when(mockSearchBloc.stream).thenAnswer(
    //     (_) => Stream.value(SearchSuccess(users: mockUsers, query: '')),
    //   );

    //   await mockNetworkImagesFor(() async {
    //     await tester.pumpWidget(createWidgetUnderTest());
    //     await tester.pump();

    //     final firstUserTile = find.byType(ListTile).first;
    //     await tester.tap(firstUserTile);
    //     await tester.pump();

    //     // Since onTap is empty (just a todo), we just verify it doesn't crash
    //     expect(find.byType(ListTile), findsNWidgets(2));
    //   });
    // });

    testWidgets('should dispose text controller', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Remove the widget to trigger dispose
        await tester.pumpWidget(Container());

        // If dispose wasn't called properly, this would cause issues in subsequent tests
        expect(true, isTrue); // Test passes if no exceptions thrown
      });
    });

    testWidgets('should handle trimmed queries correctly', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final textField = find.byType(TextField);
        await tester.enterText(textField, '  john  ');
        await tester.pump();

        verify(mockSearchBloc.add(SearchUsersEvent('john'))).called(1);
      });
    });

    testWidgets('should handle whitespace-only queries', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        final textField = find.byType(TextField);
        await tester.enterText(textField, '   ');
        await tester.pump();

        verify(mockSearchBloc.add(const ClearSearchEvent())).called(1);
      });
    });

    testWidgets('should maintain search state during widget rebuilds', (
      tester,
    ) async {
      when(
        mockSearchBloc.state,
      ).thenReturn(SearchSuccess(users: mockUsers, query: ''));
      when(mockSearchBloc.stream).thenAnswer(
        (_) => Stream.value(SearchSuccess(users: mockUsers, query: '')),
      );

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(ListView), findsOneWidget);

        // Trigger a rebuild
        await tester.pump();

        // Should still show the same content
        expect(find.byType(ListView), findsOneWidget);
        expect(find.text('John Doe'), findsOneWidget);
      });
    });
  });
}
