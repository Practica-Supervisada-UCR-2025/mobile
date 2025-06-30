import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/publications/publications.dart';
import 'package:mobile/src/home/home.dart';

class _FakeSuccessRepository implements PublicationRepository {
  @override
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
    bool? isOtherUser,
    String? time,
  }) async {
    return PublicationResponse(
      publications: [],
      totalPosts: 0,
      totalPages: 0,
      currentPage: 1,
    );
  }
}

void main() {
  testWidgets('PostsPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create:
              (_) => PublicationBloc(
                publicationRepository: _FakeSuccessRepository(),
              ),
          child: const PostsPage(isFeed: true),
        ),
      ),
    );
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });

  testWidgets('Refresh button appears after 5 minutes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create:
              (_) => PublicationBloc(
                publicationRepository: _FakeSuccessRepository(),
              ),
          child: const PostsPage(isFeed: true),
        ),
      ),
    );
    await tester.pump(const Duration(minutes: 5));
    await tester.pump();

    expect(find.text("Recent posts"), findsOneWidget);
  });

  //   testWidgets(
  //     'Pull-to-refresh calls refreshPublications and hides refresh button',
  //     (WidgetTester tester) async {
  //       await tester.pumpWidget(
  //         MaterialApp(
  //           home: BlocProvider(
  //             create:
  //                 (_) => PublicationBloc(
  //                   publicationRepository: _FakeSuccessRepository(),
  //                 ),
  //             child: const PostsPage(isFeed: true),
  //           ),
  //         ),
  //       );

  //       await tester.pump(const Duration(minutes: 5));
  //       await tester.pump();

  //       expect(find.text("Recent posts"), findsOneWidget);

  //       final refreshIndicator = tester.widget<RefreshIndicator>(
  //         find.byType(RefreshIndicator),
  //       );
  //       await refreshIndicator.onRefresh.call();
  //       await tester.pumpAndSettle();

  //       expect(find.text("Recent posts"), findsNothing);
  //     },
  //   );

  //   testWidgets(
  //     'Clicking refresh button triggers refreshPublications and hides it',
  //     (WidgetTester tester) async {
  //       await tester.pumpWidget(
  //         MaterialApp(
  //           home: BlocProvider(
  //             create:
  //                 (_) => PublicationBloc(
  //                   publicationRepository: _FakeSuccessRepository(),
  //                 ),
  //             child: const PostsPage(isFeed: true),
  //           ),
  //         ),
  //       );

  //       final state = tester.state(find.byType(PostsPage)) as dynamic;
  //       state.setState(() {
  //         state._showRefreshButton = true;
  //       });
  //       await tester.pump();

  //       expect(find.text("Recent posts"), findsOneWidget);

  //       await tester.tap(find.text("Recent posts"));
  //       await tester.pumpAndSettle();

  //       expect(find.text("Recent posts"), findsNothing);
  //     },
  //   );
}
