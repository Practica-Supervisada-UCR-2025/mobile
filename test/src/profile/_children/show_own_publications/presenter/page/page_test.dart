import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/storage/user_session.storage.dart';
import 'package:mobile/src/profile/_children/show_own_publications/presenter/page/page.dart';
import 'package:mobile/core/globals/publications/publications.dart';

class DummyPublicationRepository implements PublicationRepository {
  @override
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
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
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel preferencesChannel = MethodChannel('plugins.flutter.io/shared_preferences');
  // ignore: deprecated_member_use
  preferencesChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'getAll':
        return <String, Object>{};
      case 'setBool':
      case 'setInt':
      case 'setDouble':
      case 'setString':
      case 'setStringList':
      case 'remove':
      case 'clear':
        return true;
      default:
        return null;
    }
  });
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
  });

  late PublicationBloc bloc;

  setUp(() {
    bloc = PublicationBloc(publicationRepository: DummyPublicationRepository());
  });

  tearDown(() {
    bloc.close();
  });

  group('ShowOwnPublicationsPage', () {
    testWidgets('renders PublicationsList with isFeed=false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PublicationBloc>.value(
            value: bloc,
            child: const ShowOwnPublicationsPage(isFeed: false),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final finder = find.byType(PublicationsList);
      expect(finder, findsOneWidget);

      final widget = tester.widget<PublicationsList>(finder);
      expect(widget.isFeed, isFalse);
      expect(widget.scrollKey, 'ownPosts');
    });

    testWidgets('renders PublicationsList with isFeed=true and refresh=true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<PublicationBloc>.value(
            value: bloc,
            child: const ShowOwnPublicationsPage(isFeed: true, refresh: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final finder = find.byType(PublicationsList);
      expect(finder, findsOneWidget);

      final widget = tester.widget<PublicationsList>(finder);
      expect(widget.isFeed, isTrue);
      expect(widget.scrollKey, 'ownPosts');
    });
  });
}
