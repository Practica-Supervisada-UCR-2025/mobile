// test/page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';

void main() {
  testWidgets(
    'ShowOwnPublicationsPage builds the BlocProvider and displays PublicationsList',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ShowOwnPublicationsPage()),
      );
      expect(find.byType(BlocProvider<PublicationBloc>), findsOneWidget);
      expect(find.byType(PublicationsList), findsOneWidget);
    },
  );

  testWidgets(
    'When PublicationsList fails and Retry is pressed, the error message reappears',
    (WidgetTester tester) async {
      // Create a BLoC with a repository that always fails
      final failureBloc = PublicationBloc(
        publicationRepository: _FakeFailureRepository(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PublicationBloc>.value(
            value: failureBloc,
            child: const PublicationsList(),
          ),
        ),
      );

      // We trigger the initial load and wait for the Failure state
      failureBloc.add(LoadPublications());
      await tester.pumpAndSettle();

      // The failure message and the Retry button should be visible
      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

      // We press Retry
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));

      // Wait for the new failure to be processed
      await tester.pumpAndSettle();

      // The failure message and the Retry button should be visible again
      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    },
  );
}

/// Fake repository that always throws an exception to force the error path.
class _FakeFailureRepository implements PublicationRepository {
  @override
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
  }) {
    throw Exception('simulated failure');
  }
}
