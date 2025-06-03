import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/services/services.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockFile extends Mock implements File {
  final String fakePath = '/fake/path/image.jpg';
  
  @override
  String get path => fakePath;
}

class MockApiService extends Mock implements ApiService {}

class MockCreatePostBloc extends Mock implements CreatePostBloc {}

void main() {
  late MockApiService mockApiService;
  
  setUpAll(() {
    registerFallbackValue(const PostTextChanged(''));
    registerFallbackValue(PostImageChanged(MockFile()));
  });
  
  setUp(() {
    mockApiService = MockApiService();
  });
  
  Widget createTestableCreatePage() {
    return MultiProvider(
      providers: [
        Provider<ApiService>.value(value: mockApiService),
      ],
      child: const MaterialApp(
        home: CreatePage(),
      ),
    );
  }
  
  group('CreatePage', () {
    testWidgets('renders CreatePage and subcomponents', (tester) async {
      await tester.pumpWidget(createTestableCreatePage());

      expect(find.byType(CreatePage), findsOneWidget);
      expect(find.byType(TopActions), findsOneWidget);
      expect(find.byType(PostTextField), findsOneWidget);
      expect(find.byType(BottomBar), findsOneWidget);
    });

    testWidgets('renders a TextField with placeholder', (tester) async {
      await tester.pumpWidget(createTestableCreatePage());
      
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('What’s on your mind?'), findsOneWidget);
    });

    testWidgets('can enter text in PostTextField', (tester) async {
      await tester.pumpWidget(createTestableCreatePage());

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
        MultiProvider(
          providers: [
            Provider<ApiService>.value(value: mockApiService),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      router.push('/create');
      await tester.pumpAndSettle();

      final cancelButton = find.byIcon(Icons.close);
      expect(cancelButton, findsOneWidget);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();
    });

    testWidgets('Post button exists', (tester) async {
      await tester.pumpWidget(createTestableCreatePage());

      final postButton = find.text('Post');
      expect(postButton, findsOneWidget);
    });

    testWidgets('BottomBar contains image button icon', (tester) async {
      await tester.pumpWidget(createTestableCreatePage());

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });

    group('Image handling tests', () {
      late MockCreatePostBloc mockBloc;
      
      setUp(() {
        mockBloc = MockCreatePostBloc();
        when(() => mockBloc.add(any())).thenReturn(null);
        when(() => mockBloc.state).thenReturn(const CreatePostInitial());
      });

      testWidgets('Image selection sends PostImageChanged event to bloc', (tester) async {
        final mockBloc = MockCreatePostBloc();
        final imageFile = File('test.jpg');

        final controller = CreatePageController(
          bloc: mockBloc,
          onImageSelectedByPicker: (_) {},
        );

        controller.handleImagePicked(imageFile);

        verify(() => mockBloc.add(PostImageChanged(imageFile))).called(1);
      });

      
      testWidgets('Image removal sends PostImageChanged(null) to bloc', (tester) async {
        final mockBloc = MockCreatePostBloc();

        final controller = CreatePageController(
          bloc: mockBloc,
          onImageSelectedByPicker: (_) {},
        );

        controller.removeImage();

        verify(() => mockBloc.add(const PostImageChanged(null))).called(1);
      });
    });
  });
}
