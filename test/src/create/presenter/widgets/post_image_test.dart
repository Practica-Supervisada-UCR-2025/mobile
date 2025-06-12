import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/globals/widgets/gif_viewer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/src/create/create.dart'; 
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:network_image_mock/network_image_mock.dart';

class MockCreatePostBloc extends Mock implements CreatePostBloc {}
class MockFile extends Mock implements File {
  final String mockPath;
  
  MockFile(this.mockPath);
  
  @override
  String get path => mockPath;
  
  @override
  Future<int> length() async => 1024;
  
  @override
  Future<Uint8List> readAsBytes() async {
    return Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]);
  }
}

void main() {
  late MockCreatePostBloc mockBloc;
  
  setUpAll(() {
    registerFallbackValue(const PostTextChanged(''));
    registerFallbackValue(PostImageChanged(MockFile('')));
    registerFallbackValue(const PostGifChanged(null));
  });
  
  setUp(() {
    mockBloc = MockCreatePostBloc();
    when(() => mockBloc.state).thenReturn(const CreatePostInitial());
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(const CreatePostInitial()));
    when(() => mockBloc.add(any(that: isA<PostImageChanged>()))).thenReturn(null);    
  });
  
  Widget createWidgetUnderTest({File? image, GifModel? gifData, required VoidCallback onRemoveCallback}) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CreatePostBloc>.value(
          value: mockBloc,
          child: PostImage(
            image: image,
            gifData: gifData,
            onRemove: onRemoveCallback, 
          ),
        ),
      ),
    );
  }
  
  group('PostImage', () {

    testWidgets('renders normal image when provided non-gif image', (WidgetTester tester) async {
      final mockImage = MockFile('test_image.jpg');
      
      await tester.pumpWidget(createWidgetUnderTest(
        image: mockImage, 
        onRemoveCallback: () {},
      ));
      
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(GifImageViewer), findsNothing);
      expect(find.byType(ClipRRect), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
    
    testWidgets('renders GifImageViewer when provided gif image', (WidgetTester tester) async {
      final mockGif = MockFile('test_animation.gif');
      
      await tester.pumpWidget(createWidgetUnderTest(
        image: mockGif,
        onRemoveCallback: () {},
      ));
      await tester.pumpAndSettle();
      
      expect(find.byType(GifImageViewer), findsOneWidget);
      
      expect(find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is FileImage
      ), findsNothing);
    });

    testWidgets('calls onRemove and dispatches event when close button is tapped', (WidgetTester tester) async {
      bool removeCallbackCalled = false;
      final mockImage = MockFile('test_image.jpg');
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CreatePostBloc>.value(
              value: mockBloc,
              child: PostImage(
                image: mockImage,
                onRemove: () {
                  removeCallbackCalled = true;
                },
              ),
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.close), findsOneWidget);
      
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();
      
      expect(removeCallbackCalled, isTrue);
      
      verify(() => mockBloc.add(any(that: isA<PostImageChanged>()))).called(1);
    });
    
    testWidgets('updates image type when image changes', (WidgetTester tester) async {
      final mockImage = MockFile('test_image.jpg');
      await tester.pumpWidget(createWidgetUnderTest(
        image: mockImage,
        onRemoveCallback: () {},
      ));
      
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(GifImageViewer), findsNothing);
      
      final mockGif = MockFile('test_animation.gif');
      await tester.pumpWidget(createWidgetUnderTest(
        image: mockGif,
        onRemoveCallback: () {},
      ));
      await tester.pumpAndSettle();
      
      expect(find.byType(GifImageViewer), findsOneWidget);
      expect(find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is FileImage
      ), findsNothing);
    });

    testWidgets('calls onRemove and dispatches PostGifChanged when Tenor GIF close button is tapped', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        bool removeCallbackCalled = false;
        final mockGif = GifModel(id: 'tenor_close', tinyGifUrl: 'http://example.com/tenor_close.gif');

        when(() => mockBloc.add(any(that: isA<PostGifChanged>()))).thenReturn(null);

        await tester.pumpWidget(createWidgetUnderTest(
          gifData: mockGif,
          onRemoveCallback: () {
            removeCallbackCalled = true;
          },
        ));

        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.close), findsOneWidget);

        await tester.tap(find.byIcon(Icons.close));
        await tester.pump(); 

        expect(removeCallbackCalled, isTrue, reason: 'onRemove debe ser llamado');

        final captured = verify(() => mockBloc.add(captureAny(that: isA<PostGifChanged>()))).captured;
        expect(captured.length, 1);
        expect((captured.first as PostGifChanged).gif, isNull, reason: 'Debe despachar PostGifChanged con null');
      });
    });
  });
}