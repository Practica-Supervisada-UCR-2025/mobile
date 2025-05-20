// test/page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';

void main() {
  testWidgets(
    'ShowOwnPublicationsPage construye el BlocProvider y muestra PublicationsList',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ShowOwnPublicationsPage()),
      );
      expect(find.byType(BlocProvider<PublicationBloc>), findsOneWidget);
      expect(find.byType(PublicationsList), findsOneWidget);
    },
  );

  testWidgets(
    'Cuando PublicationsList falla y se pulsa Retry, reaparece el mensaje de error',
    (WidgetTester tester) async {
      // Creamos un BLoC con repositorio que siempre falla
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

      // Disparamos la carga inicial y esperamos al estado Failure
      failureBloc.add(LoadPublications());
      await tester.pumpAndSettle();

      // Debe verse el mensaje de fallo y el botón Retry
      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

      // Pulsamos Retry
      await tester.tap(find.widgetWithText(ElevatedButton, 'Retry'));

      // Esperamos a que termine de procesar el nuevo fallo
      await tester.pumpAndSettle();

      // De nuevo debe verse el mensaje de fallo y el botón Retry
      expect(find.text('Failed to load posts'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);
    },
  );
}

/// Repositorio falso que siempre lanza excepción para forzar la ruta de error.
class _FakeFailureRepository implements PublicationRepository {
  @override
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
  }) {
    throw Exception('simulated failure');
  }
}
