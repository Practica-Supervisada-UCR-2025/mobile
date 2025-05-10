import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/src/auth/auth.dart';
import 'package:mobile/src/settings/presenter/page/page.dart';
import 'package:mobile/src/settings/presenter/widgets/logout_button.dart';
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
        create: (_) => mockLogoutBloc,
        child: widget,
      ),
    );
  }

  group('SettingsScreen', () {
    testWidgets('muestra el título Settings en el AppBar', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutInitial());

      await tester.pumpWidget(makeTestableWidget(const SettingsScreen()));

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('muestra el texto Settings screen en el cuerpo', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutInitial());

      await tester.pumpWidget(makeTestableWidget(const SettingsScreen()));

      expect(find.text('Settings screen'), findsOneWidget);
    });

    testWidgets('contiene el widget LogoutButton', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutInitial());

      await tester.pumpWidget(makeTestableWidget(const SettingsScreen()));

      expect(find.byType(LogoutButton), findsOneWidget);
    });

    testWidgets('el AppBar tiene fondo color background', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutInitial());

      await tester.pumpWidget(makeTestableWidget(const SettingsScreen()));
      
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, ThemeData().colorScheme.surface);
    });

    testWidgets('el AppBar tiene borde inferior negro claro', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutInitial());

      await tester.pumpWidget(makeTestableWidget(const SettingsScreen()));

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      final shape = appBar.shape as Border?;
      expect(shape?.bottom.color, Colors.black12);
    });

    testWidgets('el título del AppBar tiene color AppColors.textPrimary', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutInitial());

      await tester.pumpWidget(makeTestableWidget(const SettingsScreen()));

      final text = tester.widget<Text>(find.text('Settings'));
      expect(text.style?.color, ThemeData().colorScheme.primary,);
    });

    testWidgets('el texto Settings screen tiene color AppColors.textPrimary', (tester) async {
      when(() => mockLogoutBloc.state).thenReturn(LogoutInitial());

      await tester.pumpWidget(makeTestableWidget(const SettingsScreen()));

      final text = tester.widget<Text>(find.text('Settings screen'));
      expect(text.style?.color, ThemeData().colorScheme.onSurface,);
    });
  });
}
