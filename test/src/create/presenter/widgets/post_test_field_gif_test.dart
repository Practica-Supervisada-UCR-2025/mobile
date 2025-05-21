import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

void main() {
  group('PostTextField GIF behavior', () {
    Widget buildWrappedWithMaterial(Widget child, CreatePostBloc bloc) {
      return MaterialApp(
        home: Scaffold(
          body: BlocProvider.value(
            value: bloc,
            child: MediaQuery( // necesario para el TextField
              data: const MediaQueryData(size: Size(800, 600)),
              child: child,
            ),
          ),
        ),
      );
    }

    testWidgets('muestra el GIF si state.selectedGif no es null', (WidgetTester tester) async {
      final mockGif = GifModel(id: '1', tinyGifUrl: 'https://example.com/gif.gif');
      final bloc = CreatePostBloc()
        ..emit(CreatePostChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: mockGif,
        ));

      await tester.pumpWidget(
        buildWrappedWithMaterial(PostTextField(textController: TextEditingController()), bloc),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('muestra CircularProgressIndicator si la imagen está cargando', (WidgetTester tester) async {
      final mockGif = GifModel(id: '1', tinyGifUrl: 'https://example.com/loading.gif');
      final bloc = CreatePostBloc()
        ..emit(CreatePostChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: mockGif,
        ));

      await tester.pumpWidget(
        buildWrappedWithMaterial(PostTextField(textController: TextEditingController()), bloc),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final loadingBuilder = image.loadingBuilder!;
      final testWidget = loadingBuilder(
        tester.element(find.byType(Image)),
        const Placeholder(),
        const ImageChunkEvent(cumulativeBytesLoaded: 10, expectedTotalBytes: 100),
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: testWidget)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('muestra ícono de error si la imagen no carga', (WidgetTester tester) async {
      final mockGif = GifModel(id: '1', tinyGifUrl: 'https://example.com/fail.gif');
      final bloc = CreatePostBloc()
        ..emit(CreatePostChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: mockGif,
        ));

      await tester.pumpWidget(
        buildWrappedWithMaterial(PostTextField(textController: TextEditingController()), bloc),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final errorBuilder = image.errorBuilder!;
      final testWidget = errorBuilder(
        tester.element(find.byType(Image)),
        Exception('error'),
        StackTrace.empty,
      );

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: testWidget)),
      );
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('al presionar la X dispara GifRemoved', (WidgetTester tester) async {
      final mockGif = GifModel(id: '1', tinyGifUrl: 'https://example.com/gif.gif');
      final bloc = CreatePostBloc()
        ..emit(CreatePostChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: mockGif,
        ));

      await tester.pumpWidget(
        buildWrappedWithMaterial(PostTextField(textController: TextEditingController()), bloc),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(bloc.state.selectedGif, isNull);
    });
  });
}
