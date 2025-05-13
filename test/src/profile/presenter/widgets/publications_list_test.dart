import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/src/profile/profile.dart';

class MockPublicationBloc extends Mock implements PublicationBloc {}

class FakePublicationState extends Fake implements PublicationState {}

class FakePublicationEvent extends Fake implements PublicationEvent {}

void main() {
  late PublicationBloc bloc;

  final testPublications = List.generate(
    3,
    (i) => Publication(
      id: i,
      username: 'User $i',
      profileImageUrl: 'https://example.com/$i.png',
      content: 'Post content $i',
      createdAt: DateTime.now(),
      attachment: null,
      likes: i * 10,
      comments: i * 2,
    ),
  );

  setUpAll(() {
    registerFallbackValue(FakePublicationState());
    registerFallbackValue(FakePublicationEvent());
    HttpOverrides.global = _FakeHttpOverrides();
  });

  setUp(() {
    bloc = MockPublicationBloc();
    when(() => bloc.stream).thenAnswer((_) => Stream<PublicationState>.empty());
  });

  Widget makeTestable(Widget child) {
    return MaterialApp(
      home: BlocProvider<PublicationBloc>.value(
        value: bloc,
        child: child,
      ),
    );
  }

  testWidgets('shows loading indicator when state is PublicationLoading', (tester) async {
    when(() => bloc.state).thenReturn(PublicationLoading());
    await tester.pumpWidget(makeTestable(const PublicationsList()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows error message and retry button on PublicationFailure', (tester) async {
    when(() => bloc.state).thenReturn(PublicationFailure());
    await tester.pumpWidget(makeTestable(const PublicationsList()));
    expect(find.text('Failed to load posts'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('dispatches LoadPublications when retry button is tapped', (tester) async {
    when(() => bloc.state).thenReturn(PublicationFailure());
    await tester.pumpWidget(makeTestable(const PublicationsList()));
    await tester.tap(find.text('Retry'));
    await tester.pump();
    verify(() => bloc.add(LoadPublications())).called(1);
  });

  testWidgets('renders list of PublicationCard and footer in PublicationSuccess', (tester) async {
    when(() => bloc.state).thenReturn(
      PublicationSuccess(publications: testPublications, hasReachedMax: false),
    );

    await tester.pumpWidget(makeTestable(const PublicationsList()));
    expect(find.byType(PublicationCard), findsNWidgets(testPublications.length));
    expect(find.text('No more posts to show'), findsOneWidget);
  });

  testWidgets('renders empty SizedBox for default state', (tester) async {
    when(() => bloc.state).thenReturn(PublicationInitial());
    await tester.pumpWidget(makeTestable(const PublicationsList()));
    expect(find.byType(SizedBox), findsOneWidget);
  });
}

class _FakeHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _FakeHttpClient();
  }
}

class _FakeHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeHttpClientRequest();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _FakeHttpClientResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeHttpClientResponse implements HttpClientResponse {
  final _fakeStream = Stream<Uint8List>.fromIterable([
    Uint8List.fromList([
      // Bytes de una imagen PNG válida mínima de 1x1
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41,
      0x54, 0x78, 0x9C, 0x63, 0x60, 0x00, 0x00, 0x00,
      0x02, 0x00, 0x01, 0xE5, 0x27, 0xD4, 0xA2, 0x00,
      0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82,
    ])
  ]);

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  HttpConnectionInfo? get connectionInfo => null;

  @override
  int get statusCode => 200;

  @override
  String get reasonPhrase => 'OK';

  @override
  X509Certificate? get certificate => null;

  @override
  bool get isRedirect => false;

  @override
  List<RedirectInfo> get redirects => [];

  @override
  List<Cookie> get cookies => [];

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  StreamSubscription<Uint8List> listen(
    void Function(Uint8List event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _fakeStream.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _MockHttpHeaders implements HttpHeaders {
  final _headers = <String, List<String>>{};

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _headers.putIfAbsent(name.toLowerCase(), () => []).add(value.toString());
  }

  @override
  List<String>? operator [](String name) => _headers[name];

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _headers.forEach(action);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
