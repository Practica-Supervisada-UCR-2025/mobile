import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/profile/profile.dart';

class MockPublicationBloc extends Mock implements PublicationBloc {}

class FakePublicationEvent extends Fake implements PublicationEvent {}

class FakePublicationState extends Fake implements PublicationState {}

final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  late MockPublicationBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(FakePublicationEvent());
    registerFallbackValue(FakePublicationState());
  });

  setUp(() {
    mockBloc = MockPublicationBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.state).thenReturn(PublicationInitial());
  });

  Widget buildTestableDialog() {
    return BlocProvider<PublicationBloc>.value(
      value: mockBloc,
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (_) => const DeletePublicationDialog(publicationId: '1'),
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
        navigatorKey: navigatorKey,
      ),
    );
  }


  testWidgets('renders DeletePublicationDialog UI correctly', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableDialog());
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(find.text('Do you really want to delete this post? You will not be able to undo this action.'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(find.widgetWithText(PrimaryButton, 'Delete'), findsOneWidget);
  });

  testWidgets('closes dialog when Cancel is pressed', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableDialog());
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('dispatches DeletePublicationRequested and closes dialog when Delete is pressed', (WidgetTester tester) async {
    when(() => mockBloc.add(any())).thenReturn(null);

    await tester.pumpWidget(buildTestableDialog());
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(PrimaryButton, 'Delete'));
    await tester.pumpAndSettle();

    verify(() => mockBloc.add(DeletePublicationRequested('1'))).called(1);
    expect(find.byType(AlertDialog), findsNothing);
  });
}
