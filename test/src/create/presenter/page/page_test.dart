import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mocktail/mocktail.dart';
class MockFile extends Mock implements File {
  final String fakePath = '/fake/path/image.jpg';
  
  @override
  String get path => fakePath;
}

class MockCreatePostBloc extends Mock implements CreatePostBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(const PostTextChanged(''));
    registerFallbackValue(PostImageChanged(MockFile()));
  });
  
  group('CreatePage', () {
    testWidgets('renders CreatePage and subcomponents', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      expect(find.byType(CreatePage), findsOneWidget);
      expect(find.byType(TopActions), findsOneWidget);
      expect(find.byType(PostTextField), findsOneWidget);
      expect(find.byType(BottomBar), findsOneWidget);
    });

    testWidgets('renders a TextField with placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );
      
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('What’s on your mind?'), findsOneWidget);
    });

    testWidgets('can enter text in PostTextField', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      final field = find.byType(TextField);
      expect(field, findsOneWidget);

      await tester.enterText(field, 'Hello world!');
      await tester.pump();

      expect(find.text('Hello world!'), findsOneWidget);
    });

    testWidgets('Cancel button exists and can be tapped', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => const CreatePage(),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );

      router.push('/create');
      await tester.pumpAndSettle();

      final cancelButton = find.text('Cancel');
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
    });

    testWidgets('Post button exists', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      final postButton = find.text('Post');
      expect(postButton, findsOneWidget);
    });

    testWidgets('BottomBar contains image button icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CreatePage(),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    group('Image handling tests', () {
      late MockFile mockFile;
      late MockCreatePostBloc mockBloc;
      
      setUp(() {
        mockFile = MockFile();
        mockBloc = MockCreatePostBloc();
        when(() => mockBloc.add(any())).thenReturn(null);
        when(() => mockBloc.state).thenReturn(const CreatePostInitial());
      });

      testWidgets('Image selection updates state and adds event to bloc', (tester) async {
        bool imageChanged = false;
        File? selectedImage;
        
        final controller = CreatePageController(
          bloc: mockBloc,
          onImageChanged: (image) {
            imageChanged = true;
            selectedImage = image;
          },
        );
        
        controller.handleImageSelected(mockFile);
        
        expect(imageChanged, isTrue);
        expect(selectedImage, equals(mockFile));
        expect(controller.selectedImage, equals(mockFile));
        
        verify(() => mockBloc.add(PostImageChanged(mockFile))).called(1);
      });
      
      testWidgets('Image removal updates state and adds null event to bloc', (tester) async {
        bool imageChanged = false;
        File? selectedImage = mockFile;
        
        final controller = CreatePageController(
          bloc: mockBloc,
          onImageChanged: (image) {
            imageChanged = true;
            selectedImage = image;
          },
        );
        
        controller.selectedImage = mockFile;
        
        controller.removeImage();
        
        expect(imageChanged, isTrue);
        expect(selectedImage, isNull);
        expect(controller.selectedImage, isNull);
        
        verify(() => mockBloc.add(const PostImageChanged(null))).called(1);
      });
    });
  });
}
