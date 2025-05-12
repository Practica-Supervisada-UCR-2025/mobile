import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/src/auth/auth.dart';
import 'package:mobile/src/settings/presenter/widgets/logout_button.dart';
import 'package:mobile/core/globals/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MockLogoutBloc extends Mock implements LogoutBloc {}

void main() {
  late MockLogoutBloc mockLogoutBloc;

  setUp(() {
    mockLogoutBloc = MockLogoutBloc();
    when(() => mockLogoutBloc.stream).thenAnswer((_) => Stream.value(LogoutInitial()));
    when(() => mockLogoutBloc.close()).thenAnswer((_) async => {});
  });

  tearDown(() {
    mockLogoutBloc.close();
  });

  Widget makeTestableWidget(Widget widget) {
    return MaterialApp(
      home: BlocProvider<LogoutBloc>(
        create: (context) => mockLogoutBloc,
        child: widget,
      ),
    );
  }

  group('LogoutButton', () {
    testWidgets('shows logout button and triggers event when tapped', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutInitial());
      await tester.pumpWidget(makeTestableWidget(LogoutButton()));
      expect(find.byType(PrimaryButton), findsOneWidget);
      await tester.tap(find.byType(PrimaryButton));
      await tester.pump();
      verify(() => mockLogoutBloc.add(LogoutRequested())).called(1);
    });

    testWidgets('shows loading indicator when logout is in progress', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutLoading());
      await tester.pumpWidget(makeTestableWidget(LogoutButton()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
