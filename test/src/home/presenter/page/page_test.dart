import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/home/home.dart';
import 'package:mobile/core/globals/publications/publications.dart';

class _FakeSuccessRepository implements PublicationRepository {
  @override
  Future<PublicationResponse> fetchPublications({
    int? page,
    int? limit,
    bool? isOtherUser,
    String? time,
  }) async {
    return PublicationResponse(
      publications: [],
      totalPosts: 0,
      totalPages: 0,
      currentPage: 0,
    );
  }
}

void main() {
  testWidgets('HomeScreen builds with BlocProvider', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PublicationBloc>(
          create:
              (_) => PublicationBloc(
                publicationRepository: _FakeSuccessRepository(),
              ),
          child: const HomeScreen(isFeed: true),
        ),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.text('Posts'), findsOneWidget);
    expect(find.text('News'), findsOneWidget);
  });

  testWidgets('Switching tabs shows the correct page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<PublicationBloc>(
          create:
              (_) => PublicationBloc(
                publicationRepository: _FakeSuccessRepository(),
              ),
          child: Scaffold(body: HomeScreen(isFeed: true)),
        ),
      ),
    );

    expect(find.byType(PostsPage), findsOneWidget);
    expect(find.byType(NewsPage), findsNothing);

    await tester.tap(find.text('News'));
    await tester.pumpAndSettle();

    expect(find.byType(NewsPage), findsOneWidget);
    expect(find.byType(PostsPage), findsNothing);

    await tester.tap(find.text('Posts'));
    await tester.pumpAndSettle();

    expect(find.byType(PostsPage), findsOneWidget);
    expect(find.byType(NewsPage), findsNothing);
  });
}
