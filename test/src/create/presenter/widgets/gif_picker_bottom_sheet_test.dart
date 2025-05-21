
import 'dart:async'; 

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/models/trending_response.dart';
import 'package:mobile/src/shared/services/tenor_gif_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';

// --- Mocks ---
class MockTenorGifService extends Mock implements TenorGifService {}

class MockCreatePostBloc extends Mock implements CreatePostBloc {
  @override
  final CreatePostState state = const CreatePostInitial();
  @override
  Stream<CreatePostState> get stream => Stream.value(state);
  @override
  Future<void> close() async {}
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

GifModel createSampleGif(String id, String url) {
  return GifModel(id: id, tinyGifUrl: url);
}

void main() {
  late MockTenorGifService mockGifService;
  late MockCreatePostBloc mockCreatePostBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  final mockGif1 = createSampleGif('id1', 'http://example.com/gif1.gif');
  final mockGif2 = createSampleGif('id2', 'http://example.com/gif2.gif');
  final mockGif3 = createSampleGif('id3', 'http://example.com/gif3.gif');

  setUpAll(() {
    registerFallbackValue(GifSelected(createSampleGif('fallback', 'http://fallback.com/gif.gif')));
    registerFallbackValue(FakeRoute());
    registerFallbackValue(null as String?);
    registerFallbackValue(0);
  });

  setUp(() {
    mockGifService = MockTenorGifService();
    mockCreatePostBloc = MockCreatePostBloc();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Widget buildTestableWidget({Key? key, MockTenorGifService? gifService, MockCreatePostBloc? createPostBloc}) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CreatePostBloc>.value(
          value: createPostBloc ?? MockCreatePostBloc(),
          child: GifPickerBottomSheet(
            key: key ?? UniqueKey(),
            gifService: gifService ?? MockTenorGifService(),
          ),
        ),
      ),
      navigatorObservers: [mockNavigatorObserver],
    );
  }

  group('GifPickerBottomSheet Simplified Tests', () {
    testWidgets('1. Debe mostrar indicador de carga y luego GIFs populares al iniciar', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final trendingResponse = TrendingGifResponse(gifs: [mockGif1, mockGif2], next: 'nextPos');
        when(() => mockGifService.getTrendingGifs(pos: any(named: 'pos')))
            .thenAnswer((_) async {
          await Future.delayed(Duration.zero);
          return trendingResponse;
        });

        await tester.pumpWidget(buildTestableWidget(gifService: mockGifService, createPostBloc: mockCreatePostBloc));
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing, reason: "Loader debería desaparecer tras la carga");
        expect(find.byType(Image), findsNWidgets(2), reason: "Deberían mostrarse 2 GIFs populares");
        verify(() => mockGifService.getTrendingGifs(pos: null)).called(1);
      });
    });

    testWidgets('2. Debe buscar GIFs y mostrarlos (verificando loader intermedio)', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        const searchQuery = 'cats';
        when(() => mockGifService.getTrendingGifs(pos: any(named: 'pos')))
            .thenAnswer((_) async => TrendingGifResponse(gifs: [], next: null));
        when(() => mockGifService.searchGifs(searchQuery, pos: 0))
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 10));
          return [mockGif1, mockGif3];
        });

        await tester.pumpWidget(buildTestableWidget(gifService: mockGifService, createPostBloc: mockCreatePostBloc));
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);
        await tester.enterText(textField, searchQuery);
        await tester.testTextInput.receiveAction(TextInputAction.done);

        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: "Loader durante búsqueda");

        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(Image), findsNWidgets(2));
        verify(() => mockGifService.searchGifs(searchQuery, pos: 0)).called(1);
      });
    });

    testWidgets('3. Debe volver a cargar GIFs populares si la búsqueda se limpia', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        const searchQuery = 'dogs';
        final trendingAfterClear = TrendingGifResponse(gifs: [mockGif2, mockGif3], next: 'next2');

        when(() => mockGifService.getTrendingGifs(pos: null))
            .thenAnswer((invocation) async {
          return TrendingGifResponse(gifs: [mockGif1], next: 'next1');
        });
        when(() => mockGifService.searchGifs(searchQuery, pos: 0))
            .thenAnswer((_) async => [createSampleGif('dog1', 'http://example.com/dog1.gif')]);
        when(() => mockGifService.getTrendingGifs(pos: null))
            .thenAnswer((invocation) async {
          return trendingAfterClear;
        });

        await tester.pumpWidget(buildTestableWidget(gifService: mockGifService, createPostBloc: mockCreatePostBloc));
        await tester.pumpAndSettle();

        final textField = find.byType(TextField);
        await tester.enterText(textField, searchQuery);
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();

        await tester.enterText(textField, '');
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNWidgets(2), reason: "Deberían mostrarse los nuevos GIFs populares");
        expect(find.image(NetworkImage(mockGif2.tinyGifUrl)), findsOneWidget);
        expect(find.image(NetworkImage(mockGif3.tinyGifUrl)), findsOneWidget);

        verify(() => mockGifService.getTrendingGifs(pos: null)).called(2);
        verify(() => mockGifService.searchGifs(searchQuery, pos: 0)).called(1);
      });
    });

    testWidgets('4. Debe seleccionar un GIF, llamar a CreatePostBloc y cerrar', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final trendingResponse = TrendingGifResponse(gifs: [mockGif1], next: null);
        when(() => mockGifService.getTrendingGifs(pos: any(named: 'pos'))).thenAnswer((_) async => trendingResponse);

        await tester.pumpWidget(buildTestableWidget(gifService: mockGifService, createPostBloc: mockCreatePostBloc));
        await tester.pumpAndSettle();

        final gifToTap = find.image(NetworkImage(mockGif1.tinyGifUrl));
        await tester.tap(gifToTap);
        await tester.pumpAndSettle();

        final captured = verify(() => mockCreatePostBloc.add(captureAny(that: isA<GifSelected>()))).captured;
        expect(captured.length, 1);
        expect((captured.first as GifSelected).gif.id, mockGif1.id);
        verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
        expect(find.byType(GifPickerBottomSheet), findsNothing);
      });
    });

    testWidgets('5. Debe cargar más GIFs (populares) al hacer scroll', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final page1Trending = TrendingGifResponse(
          gifs: List.generate(12, (i) => GifModel(id: 'gif$i', tinyGifUrl: 'http://example.com/gif$i.gif')),
          next: 'nextPage2',
        );
        final page2Trending = TrendingGifResponse(
          gifs: [GifModel(id: 'gif12', tinyGifUrl: 'http://example.com/gif12.gif')],
          next: null,
        );

        when(() => mockGifService.getTrendingGifs(pos: null)).thenAnswer((_) async => page1Trending);
        when(() => mockGifService.getTrendingGifs(pos: 'nextPage2')).thenAnswer((_) async => page2Trending);

        await tester.binding.setSurfaceSize(const Size(400, 1200));
        await tester.pumpWidget(buildTestableWidget(gifService: mockGifService, createPostBloc: mockCreatePostBloc));
        await tester.pumpAndSettle();

        await tester.dragUntilVisible(
          find.image(NetworkImage('http://example.com/gif11.gif')),
          find.byType(GridView),
          const Offset(0.0, -1000.0),
        );
        await tester.pumpAndSettle();

        expect(find.image(NetworkImage('http://example.com/gif12.gif')), findsOneWidget);
        verify(() => mockGifService.getTrendingGifs(pos: 'nextPage2')).called(1);
      });
    });

    
  });
}