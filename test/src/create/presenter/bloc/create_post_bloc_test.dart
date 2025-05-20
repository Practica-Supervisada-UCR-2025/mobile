import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/src/create/presenter/bloc/create_post_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockFile extends Mock implements File {}

void main() {
  late CreatePostBloc createPostBloc;
  late File mockImage;

  setUp(() {
    createPostBloc = CreatePostBloc();
    mockImage = MockFile();
  });

  tearDown(() {
    createPostBloc.close();
  });

  group('CreatePostBloc', () {
    test('initial state of CreatePostBloc should be CreatePostInitial', () {
      expect(createPostBloc.state, isA<CreatePostInitial>());
    });

    test('PostTextChanged props should include text', () {
      const eventA = PostTextChanged('Test text');
      const eventB = PostTextChanged('Test text');
      const eventC = PostTextChanged('Different text');

      expect(eventA.props, ['Test text']);
      expect(eventA, equals(eventB));
      expect(eventA == eventC, isFalse);
    });

    test('PostImageChanged props should include image', () {
      final eventA = PostImageChanged(mockImage);
      final eventB = PostImageChanged(mockImage);
      final eventC = PostImageChanged(null);

      expect(eventA.props, [mockImage]);
      expect(eventA, equals(eventB));
      expect(eventA == eventC, isFalse);
    });

    test('CreatePostInitial should have default values', () {
      final initialState = createPostBloc.state;

      expect(initialState, isA<CreatePostInitial>());
      expect(initialState.text, '');
      expect(initialState.image, null);
      expect(initialState.isOverLimit, false);
      expect(initialState.isValid, false);
    });

    // Text change tests
    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with valid text when text is within the limit',
      build: () => createPostBloc,
      act: (bloc) => bloc.add(const PostTextChanged('Valid post text')),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', 'Valid post text')
            .having((state) => state.isOverLimit, 'isOverLimit', false)
            .having((state) => state.isValid, 'isValid', true),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isOverLimit true when text exceeds the limit',
      build: () => createPostBloc,
      act: (bloc) => bloc.add(PostTextChanged('A' * 301)), // 301 characters
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', 'A' * 301)
            .having((state) => state.isOverLimit, 'isOverLimit', true)
            .having((state) => state.isValid, 'isValid', false),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isValid false when text is empty',
      build: () => createPostBloc,
      act: (bloc) => bloc.add(const PostTextChanged('')),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', '')
            .having((state) => state.isOverLimit, 'isOverLimit', false)
            .having((state) => state.isValid, 'isValid', false),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isValid true when text is exactly at the limit',
      build: () => createPostBloc,
      act: (bloc) => bloc.add(PostTextChanged('A' * 300)), // 300 characters
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', 'A' * 300)
            .having((state) => state.isOverLimit, 'isOverLimit', false)
            .having((state) => state.isValid, 'isValid', true),
      ],
    );

    // Image change tests
    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isValid true when adding an image with no text',
      build: () => createPostBloc,
      act: (bloc) => bloc.add(PostImageChanged(mockImage)),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', '')
            .having((state) => state.image, 'image', mockImage)
            .having((state) => state.isOverLimit, 'isOverLimit', false)
            .having((state) => state.isValid, 'isValid', true),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isValid true when adding an image with valid text',
      build: () => createPostBloc,
      seed: () => const CreatePostChanged(
        text: 'Valid text',
        image: null,
        isOverLimit: false,
        isValid: true,
      ),
      act: (bloc) => bloc.add(PostImageChanged(mockImage)),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', 'Valid text')
            .having((state) => state.image, 'image', mockImage)
            .having((state) => state.isOverLimit, 'isOverLimit', false)
            .having((state) => state.isValid, 'isValid', true),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isValid false when adding an image with text over limit',
      build: () => createPostBloc,
      seed: () => CreatePostChanged(
        text: 'A' * 301,
        image: null,
        isOverLimit: true,
        isValid: false,
      ),
      act: (bloc) => bloc.add(PostImageChanged(mockImage)),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', 'A' * 301)
            .having((state) => state.image, 'image', mockImage)
            .having((state) => state.isOverLimit, 'isOverLimit', true)
            .having((state) => state.isValid, 'isValid', false),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isValid true when removing image but having valid text',
      build: () => createPostBloc,
      seed: () => CreatePostChanged(
        text: 'Valid text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
      ),
      act: (bloc) => bloc.add(const PostImageChanged(null)),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', 'Valid text')
            .having((state) => state.image, 'image', null)
            .having((state) => state.isOverLimit, 'isOverLimit', false)
            .having((state) => state.isValid, 'isValid', true),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isValid false when removing image with empty text',
      build: () => createPostBloc,
      seed: () => CreatePostChanged(
        text: '',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
      ),
      act: (bloc) => bloc.add(const PostImageChanged(null)),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', '')
            .having((state) => state.image, 'image', null)
            .having((state) => state.isOverLimit, 'isOverLimit', false)
            .having((state) => state.isValid, 'isValid', false),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [CreatePostChanged] with isValid false when removing image with text over limit',
      build: () => createPostBloc,
      seed: () => CreatePostChanged(
        text: 'A' * 301,
        image: mockImage,
        isOverLimit: true,
        isValid: false,
      ),
      act: (bloc) => bloc.add(const PostImageChanged(null)),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', 'A' * 301)
            .having((state) => state.image, 'image', null)
            .having((state) => state.isOverLimit, 'isOverLimit', true)
            .having((state) => state.isValid, 'isValid', false),
      ],
    );
  });
}