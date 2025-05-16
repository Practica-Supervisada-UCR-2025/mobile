import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/src/profile/profile.dart';

class MockPublicationBloc extends Mock implements PublicationBloc {}

class FakePublicationEvent extends Fake implements PublicationEvent {}
class FakePublicationState extends Fake implements PublicationState {}

class MockPublicationRepository extends Mock implements PublicationRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakePublicationEvent());
    registerFallbackValue(FakePublicationState());
  });

  testWidgets('ShowOwnPublicationsPage renders PublicationsList and dispatches LoadPublications',
      (WidgetTester tester) async {
    // Arrange
    final mockRepository = MockPublicationRepository();

    await tester.pumpWidget(
      MaterialApp(
        home: RepositoryProvider<PublicationRepository>.value(
          value: mockRepository,
          child: const ShowOwnPublicationsPage(),
        ),
      ),
    );

    // Act
    await tester.pump(); // Dispara la construcción de BlocProvider y la lista

    // Assert
    expect(find.byType(PublicationsList), findsOneWidget);
  });
}
