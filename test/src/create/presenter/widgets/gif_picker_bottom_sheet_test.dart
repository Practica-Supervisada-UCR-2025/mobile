import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/src/create/presenter/widgets/gif_picker_bottom_sheet.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/models/trending_response.dart';
import 'package:mobile/src/shared/services/tenor_gif_service.dart';

class MockTenorGifService extends Mock implements TenorGifService {}

void main() {
  late MockTenorGifService mockService;
  late GifModel gif1;
  late GifModel gif2;

  setUp(() {
    mockService = MockTenorGifService();
    gif1 = GifModel(id: '1', tinyGifUrl: 'https://example.com/gif1.gif');
    gif2 = GifModel(id: '2', tinyGifUrl: 'https://example.com/gif2.gif');
  });

  Widget createWidgetUnderTest({required void Function(GifModel) onGifSelected}) {
    return MaterialApp(
      home: Scaffold(
        body: GifPickerBottomSheet(
          gifService: mockService,
          onGifSelected: onGifSelected,
        ),
      ),
    );
  }

  testWidgets('loads trending GIFs and displays images', (tester) async {
    when(() => mockService.getTrendingGifs(pos: null))
        .thenAnswer((_) async => TrendingGifResponse(gifs: [gif1, gif2], next: null));

    await tester.pumpWidget(
      createWidgetUnderTest(onGifSelected: (_) {}),
    );
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsNWidgets(2));
  });

  testWidgets('searches and displays GIFs when query is submitted', (tester) async {
    when(() => mockService.getTrendingGifs(pos: null))
        .thenAnswer((_) async => TrendingGifResponse(gifs: [], next: null));
    when(() => mockService.searchGifs('funny cat', pos: 0))
        .thenAnswer((_) async => [gif1]);

    await tester.pumpWidget(
      createWidgetUnderTest(onGifSelected: (_) {}),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'funny cat');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.image(NetworkImage(gif1.tinyGifUrl)), findsOneWidget);
  });

  testWidgets('calls onGifSelected when a GIF is tapped', (tester) async {
    GifModel? selected;

    when(() => mockService.getTrendingGifs(pos: null))
        .thenAnswer((_) async => TrendingGifResponse(gifs: [gif1], next: null));

    await tester.pumpWidget(
      createWidgetUnderTest(onGifSelected: (gif) => selected = gif),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Image).first);
    await tester.pump();

    expect(selected, isNotNull);
    expect(selected!.id, equals('1'));
  });

  testWidgets('displays loading indicator while fetching GIFs', (tester) async {
    when(() => mockService.getTrendingGifs(pos: null))
        .thenAnswer((_) async => TrendingGifResponse(gifs: [], next: null));

    await tester.pumpWidget(
      createWidgetUnderTest(onGifSelected: (_) {}),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
