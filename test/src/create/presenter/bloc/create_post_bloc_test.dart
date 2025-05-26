import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mocktail/mocktail.dart';

class MockFile extends Mock implements File {}
class MockCreatePostRepository extends Mock implements CreatePostRepository {}

void main() {
  late CreatePostBloc createPostBloc;
  late File mockImage;
  late MockCreatePostRepository mockRepository;

  setUp(() {
    mockRepository = MockCreatePostRepository();
    createPostBloc = CreatePostBloc(createPostRepository: mockRepository);
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
      expect(initialState.selectedGif, null);
    });

    test('PostTextChanged props should return correct values', () {
      const event = PostTextChanged('Test text');
      expect(event.props, ['Test text']);
    });

    test('PostImageChanged props should return correct values', () {
      final event = PostImageChanged(mockImage);
      expect(event.props, [mockImage]);
    });

    test('PostGifChanged props should return correct values', () {
      final gif = GifModel(id: '123', tinyGifUrl: 'https://example.com/gif');
      final event = PostGifChanged(gif);
      expect(event.props, [gif]);
    });

    test('PostSubmitted props should return correct values', () {
      final gif = GifModel(id: '123', tinyGifUrl: 'https://example.com/gif');
      final event = PostSubmitted(text: 'Test', image: mockImage, selectedGif: gif);
      expect(event.props, ['Test', mockImage, gif]);
    });

    test('CreatePostInitial.copyWith should return the same instance when no arguments are provided', () {
      const initialState = CreatePostInitial();
      final copiedState = initialState.copyWith();
      expect(copiedState, same(initialState));
    });

    test('CreatePostInitial.copyWith should override values when arguments are provided', () {
      const initialState = CreatePostInitial();
      final updatedState = initialState.copyWith(
        text: 'Updated text',
        isValid: true,
      );
      expect(updatedState, isA<CreatePostChanged>());
      expect(updatedState.text, 'Updated text');
      expect(updatedState.isValid, true);
    });

    test('CreatePostInitial.copyWith should override text when provided', () {
      const initialState = CreatePostInitial();
      final updatedState = initialState.copyWith(text: 'Updated text');
      expect(updatedState, isA<CreatePostChanged>());
      expect(updatedState.text, 'Updated text');
      expect(updatedState.isValid, false);
    });

    test('CreatePostInitial.copyWith should override isValid when provided', () {
      const initialState = CreatePostInitial();
      final updatedState = initialState.copyWith(isValid: true);
      expect(updatedState, isA<CreatePostChanged>());
      expect(updatedState.isValid, true);
      expect(updatedState.text, '');
    });

    test('CreatePostInitial.copyWith should override multiple values when provided', () {
      const initialState = CreatePostInitial();
      final updatedState = initialState.copyWith(
        text: 'Updated text',
        isValid: true,
        isOverLimit: true,
      );
      expect(updatedState, isA<CreatePostChanged>());
      expect(updatedState.text, 'Updated text');
      expect(updatedState.isValid, true);
      expect(updatedState.isOverLimit, true);
    });

    test('PostSubmitting.copyWith should return the same instance when no arguments are provided', () {
      final state = PostSubmitting(
        text: 'Submitting text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final copiedState = state.copyWith();
      expect(copiedState, equals(state));
    });

    test('PostSubmitting.copyWith should override values when arguments are provided', () {
      final state = PostSubmitting(
        text: 'Submitting text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final updatedState = state.copyWith(
        isValid: false,
        text: 'Updated text',
      );
      expect(updatedState.isValid, false);
      expect(updatedState.text, 'Updated text');
    });

    test('PostSubmitSuccess.copyWith should return the same instance when no arguments are provided', () {
      final state = PostSubmitSuccess(
        text: 'Success text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final copiedState = state.copyWith();
      expect(copiedState, equals(state)); // Debe ser igual al estado original
    });

    test('PostSubmitSuccess.copyWith should override values when arguments are provided', () {
      final state = PostSubmitSuccess(
        text: 'Success text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final updatedState = state.copyWith(
        text: 'Updated text',
        isValid: false,
      );
      expect(updatedState.text, 'Updated text');
      expect(updatedState.isValid, false);
    });

    test('PostSubmitFailure.copyWith should return the same instance when no arguments are provided', () {
      final state = PostSubmitFailure(
        text: 'Failure text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
        error: 'Error message',
      );
      final copiedState = state.copyWith();
      expect(copiedState, equals(state)); // Debe ser igual al estado original
    });

    test('PostSubmitFailure.copyWith should override values when arguments are provided', () {
      final state = PostSubmitFailure(
        text: 'Failure text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
        error: 'Error message',
      );
      final updatedState = state.copyWith(
        error: 'Updated error',
        isValid: false,
      );
      expect((updatedState as PostSubmitFailure).error, 'Updated error');
      expect(updatedState.isValid, false);
    });
    test('CreatePostInitial.copyWith should return updated state', () {
      const initialState = CreatePostInitial();
      final updatedState = initialState.copyWith(text: 'Updated text', isValid: true);
      expect(updatedState, isA<CreatePostChanged>());
      expect(updatedState.text, 'Updated text');
      expect(updatedState.isValid, true);
    });

    test('CreatePostChanged.copyWith should return updated state', () {
      final state = CreatePostChanged(
        text: 'Initial text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final updatedState = state.copyWith(text: 'Updated text', isValid: false);
      expect(updatedState.text, 'Updated text');
      expect(updatedState.isValid, false);
    });

    test('PostSubmitting.copyWith should return updated state', () {
      final state = PostSubmitting(
        text: 'Submitting text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final updatedState = state.copyWith(isValid: false);
      expect(updatedState.isValid, false);
    });

    test('PostSubmitSuccess.copyWith should return updated state', () {
      final state = PostSubmitSuccess(
        text: 'Success text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final updatedState = state.copyWith(text: 'Updated text');
      expect(updatedState.text, 'Updated text');
    });

    test('PostSubmitFailure.copyWith should return updated state', () {
      final state = PostSubmitFailure(
        text: 'Failure text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
        error: 'Error message',
      );
      final updatedState = state.copyWith(error: 'Updated error');
      expect((updatedState as PostSubmitFailure).error, 'Updated error');
      expect(updatedState.text, 'Failure text');
      expect(updatedState.image, mockImage);
      expect(updatedState.isOverLimit, false);
      expect(updatedState.isValid, true);
      expect(updatedState.selectedGif, null);
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
      act: (bloc) => bloc.add(PostTextChanged('A' * 301)), 
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
      act: (bloc) => bloc.add(PostTextChanged('A' * 300)),
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.text, 'text', 'A' * 300)
            .having((state) => state.isOverLimit, 'isOverLimit', false)
            .having((state) => state.isValid, 'isValid', true),
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit new state with selectedGif when GifSelected is added',
      build: () => createPostBloc,
      act: (bloc) {
        final gif = GifModel(id: '123', tinyGifUrl: 'https://media.tenor.com/sample.gif');
        bloc.add(PostGifChanged(gif));
      },
      expect: () => [
        isA<CreatePostChanged>() 
            .having((state) => state.text, 'text', '') 
            .having((state) => state.image, 'image', null) 
            .having((state) => state.selectedGif?.id, 'selectedGif.id', '123')
            .having((state) => state.selectedGif?.tinyGifUrl, 'selectedGif.tinyGifUrl', 'https://media.tenor.com/sample.gif') 
            .having((state) => state.isOverLimit, 'isOverLimit', false) 
            .having((state) => state.isValid, 'isValid', true), 
      ],
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should not emit new state when GIF is too large',
      build: () => createPostBloc,
      act: (bloc) {
        final largeGif = GifModel(id: 'big', tinyGifUrl: 'url', sizeBytes: 6 * 1024 * 1024);
        bloc.add(PostGifChanged(largeGif));
      },
      expect: () => [],
    );

    test('CreatePostChanged.copyWith returns new instance with updated values', () {
      final original = CreatePostChanged(
        text: 'Hello',
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
        image: null,
      );

      final updated = original.copyWith(
        text: 'Updated text',
        isOverLimit: true,
        isValid: false,
        selectedGif: GifModel(id: '1', tinyGifUrl: 'url'),
      );

      expect(updated.text, 'Updated text');
      expect(updated.isOverLimit, true);
      expect(updated.isValid, false);
      expect(updated.selectedGif?.id, '1');
    });

    test('CreatePostInitial.copyWith returns CreatePostChanged with overridden values', () {
      final initial = const CreatePostInitial();

      final newState = initial.copyWith(
        text: 'Copied',
        isOverLimit: true,
        isValid: false,
        selectedGif: GifModel(id: '42', tinyGifUrl: 'https://tenor.com/gif42.gif'),
        image: mockImage,
      );

      expect(newState, isA<CreatePostChanged>());
      expect(newState.text, 'Copied');
      expect(newState.isOverLimit, true);
      expect(newState.isValid, false);
      expect(newState.selectedGif?.id, '42');
      expect(newState.image, mockImage);
    });

    test('CreatePostChanged.copyWith without arguments returns identical state', () {
      final gif = GifModel(id: 'abc', tinyGifUrl: 'https://tenor.com/abc.gif');

      final original = CreatePostChanged(
        text: 'unchanged',
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
        image: null,
      );

      final copied = original.copyWith();

      expect(copied, equals(original));
      expect(identical(copied, original), isFalse, reason: 'copyWith should return a new instance');
    });

    test('CreatePostChanged props and equality', () {
      final gif = GifModel(id: '1', tinyGifUrl: 'url');
      final imageFile = MockFile();
      final state1 = CreatePostChanged(
        text: 'text',
        image: imageFile,
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );
      final state2 = CreatePostChanged(
        text: 'text',
        image: imageFile,
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );

      expect(state1.props, equals(['text', imageFile, false, true, gif]));
      expect(state1, equals(state2));
    });
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
        selectedGif: null,
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
        selectedGif: null,
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
        selectedGif: null,
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
        selectedGif: null,
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
        selectedGif: null,
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

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [PostSubmitting, PostSubmitSuccess] when post is successfully submitted',
      build: () {
        when(() => mockRepository.createPost(
          text: any(named: 'text'),
          image: any(named: 'image'),
          selectedGif: any(named: 'selectedGif'),
        )).thenAnswer((_) async {});
        return createPostBloc;
      },
      act: (bloc) => bloc.add(PostSubmitted(text: 'Test post', image: mockImage)),
      expect: () => [
        isA<PostSubmitting>()
            .having((state) => state.text, 'text', 'Test post')
            .having((state) => state.image, 'image', mockImage),
        isA<PostSubmitSuccess>()
            .having((state) => state.text, 'text', 'Test post')
            .having((state) => state.image, 'image', mockImage),
      ],
      verify: (_) {
        verify(() => mockRepository.createPost(
          text: 'Test post',
          image: mockImage,
          selectedGif: null,
        )).called(1);
      },
    );

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit [PostSubmitting, PostSubmitFailure] when post submission fails',
      build: () {
        when(() => mockRepository.createPost(
          text: any(named: 'text'),
          image: any(named: 'image'),
          selectedGif: any(named: 'selectedGif'),
        )).thenThrow(Exception('Submission failed'));
        return createPostBloc;
      },
      act: (bloc) => bloc.add(PostSubmitted(text: 'Test post', image: mockImage)),
      expect: () => [
        isA<PostSubmitting>()
            .having((state) => state.text, 'text', 'Test post')
            .having((state) => state.image, 'image', mockImage),
        isA<PostSubmitFailure>()
            .having((state) => state.text, 'text', 'Test post')
            .having((state) => state.image, 'image', mockImage)
            .having((state) => state.error, 'error', 'Exception: Submission failed'),
      ],
      verify: (_) {
        verify(() => mockRepository.createPost(
          text: 'Test post',
          image: mockImage,
          selectedGif: null,
        )).called(1);
      },
    );
  });
}