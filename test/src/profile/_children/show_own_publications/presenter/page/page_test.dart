import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile/core/globals/publications/publications.dart';
import 'package:mobile/src/profile/_children/_children.dart';

void main() {
  // testWidgets(
  //   'ShowOwnPublicationsPage builds the BlocProvider and displays PublicationsList',
  //   (WidgetTester tester) async {
  //     await tester.pumpWidget(
  //       MaterialApp(home: ShowOwnPublicationsPage(isFeed: false)),
  //     );
  //     expect(find.byType(BlocProvider<PublicationBloc>), findsOneWidget);
  //     expect(find.byType(PublicationsList), findsOneWidget);
  //   },
  // );

  testWidgets(
    'When PublicationsList fails and Retry is pressed, the error message reappears',
    (WidgetTester tester) async {
      final failureBloc = PublicationBloc(
        publicationRepository: _FakeFailureRepository(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PublicationBloc>.value(
            value: failureBloc,
            child: const PublicationsList(scrollKey: "homePage", isFeed: false, isOtherUser: false),
          ),
        ),
      );

      failureBloc.add(LoadPublications());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));

      await tester.pumpAndSettle();

      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    },
  );
}

class _FakeFailureRepository implements PublicationRepository {
  @override
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
    bool? isOtherUser,
    String? time,
  }) {
    throw Exception('simulated failure');
  }
}