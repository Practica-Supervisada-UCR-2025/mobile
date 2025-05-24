import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/create/create.dart'; 
import 'package:mocktail/mocktail.dart';

class MockCreatePostBloc extends Mock implements CreatePostBloc {
  @override
  CreatePostState get state => const CreatePostInitial(); 

  @override
  Stream<CreatePostState> get stream => Stream.value(const CreatePostInitial());
}
void main() {
  late TextEditingController textController;
  late MockCreatePostBloc mockCreatePostBloc;

  setUpAll(() {
    registerFallbackValue(const PostTextChanged('fallback_text'));
  });

  setUp(() {
    textController = TextEditingController();
    mockCreatePostBloc = MockCreatePostBloc();
  });

  tearDown(() {
    textController.dispose();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<CreatePostBloc>.value(
          value: mockCreatePostBloc, 
          child: MediaQuery(
            data: const MediaQueryData(size: Size(800, 600)),
            child: child,
          ),
        ),
      ),
    );
  }

  group('PostTextField', () {
    testWidgets('renders correctly with hintText and no border', (WidgetTester tester) async {
      when(() => mockCreatePostBloc.add(any())).thenAnswer((_) async {});


      await tester.pumpWidget(
        buildTestableWidget(PostTextField(textController: textController)),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('What’s on your mind?'), findsOneWidget);

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration!.border, InputBorder.none);
      expect(textField.decoration!.counterText, '');
      expect(textField.autofocus, isTrue);
      expect(textField.maxLines, null);
    });

    testWidgets('updates textController when text is entered', (WidgetTester tester) async {
      when(() => mockCreatePostBloc.add(any())).thenAnswer((_) async {});

      await tester.pumpWidget(
        buildTestableWidget(PostTextField(textController: textController)),
      );

      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();

      expect(textController.text, 'Hello world');
    });

    testWidgets('adds PostTextChanged event to CreatePostBloc on text change', (WidgetTester tester) async {
      when(() => mockCreatePostBloc.add(any(that: isA<PostTextChanged>())))
          .thenAnswer((_) async {}); 

      await tester.pumpWidget(
        buildTestableWidget(PostTextField(textController: textController)),
      );

      const testText = 'Testing bloc event';
      await tester.enterText(find.byType(TextField), testText);
      await tester.pump();

      final captured = verify(() => mockCreatePostBloc.add(captureAny(that: isA<PostTextChanged>())))
          .captured;

      expect(captured.length, 1);
      expect(captured.first, isA<PostTextChanged>());
      expect((captured.first as PostTextChanged).text, testText);
    });
  });
}