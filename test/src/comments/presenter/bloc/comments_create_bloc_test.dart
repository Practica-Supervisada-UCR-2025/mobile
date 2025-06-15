import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mocktail/mocktail.dart';

class MockFile extends Mock implements File {}
class MockCommentsRepository extends Mock implements CommentsRepository {}

void main() {
  late CommentsCreateBloc commentsCreateBloc;
  late File mockImage;
  late MockCommentsRepository mockRepository;

  setUp(() {
    mockRepository = MockCommentsRepository();
    commentsCreateBloc = CommentsCreateBloc(commentsRepository: mockRepository);
    mockImage = MockFile();
  });

  tearDown(() {
    commentsCreateBloc.close();
  });

  group('CommentsCreateBloc', () {
    test('initial state of CommentsCreateBloc should be CommentChanged with default values', () {
      expect(commentsCreateBloc.state, isA<CommentChanged>());
      expect(commentsCreateBloc.state.text, '');
      expect(commentsCreateBloc.state.image, null);
      expect(commentsCreateBloc.state.isOverLimit, false);
      expect(commentsCreateBloc.state.isValid, false);
      expect(commentsCreateBloc.state.selectedGif, null);
    });

    test('CommentTextChanged props should include text', () {
      const eventA = CommentTextChanged('Test text');
      const eventB = CommentTextChanged('Test text');
      const eventC = CommentTextChanged('Different text');

      expect(eventA.props, ['Test text']);
      expect(eventA, equals(eventB));
      expect(eventA == eventC, isFalse);
    });

    test('CommentImageChanged props should include image', () {
      final eventA = CommentImageChanged(mockImage);
      final eventB = CommentImageChanged(mockImage);
      final eventC = CommentImageChanged(null);

      expect(eventA.props, [mockImage]);
      expect(eventA, equals(eventB));
      expect(eventA == eventC, isFalse);
    });

    test('CommentGifChanged props should return correct values', () {
      final gif = GifModel(id: '123', tinyGifUrl: 'https://example.com/gif');
      final event = CommentGifChanged(gif);
      expect(event.props, [gif]);
    });

    test('CommentSubmitted props should return correct values', () {
      final gif = GifModel(id: '123', tinyGifUrl: 'https://example.com/gif');
      final event = CommentSubmitted(
        postId: 'post123',
        text: 'Test',
        image: mockImage,
        selectedGif: gif,
      );
      expect(event.props, ['post123', 'Test', mockImage, gif]);
    });

    test('CommentReset props should return correct values', () {
      const event = CommentReset();
      expect(event.props, []);
    });

    test('CommentChanged.copyWith should return the same instance when no arguments are provided', () {
      final initialState = CommentChanged(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final copiedState = initialState.copyWith();
      expect(copiedState.text, initialState.text);
      expect(copiedState.isValid, initialState.isValid);
    });

    test('CommentChanged.copyWith should override values when arguments are provided', () {
      final initialState = CommentChanged(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: false,
        selectedGif: null,
      );
      final updatedState = initialState.copyWith(isValid: true);
      expect(updatedState.isValid, true);
    });

    test('CommentChanged.copyWith should override text when provided', () {
      final initialState = CommentChanged(
        text: 'original',
        image: null,
        isOverLimit: false,
        isValid: false,
        selectedGif: null,
      );
      final updatedState = initialState.copyWith(text: 'updated');
      expect(updatedState.text, 'updated');
    });

    test('CommentChanged.copyWith should override multiple values when provided', () {
      final initialState = CommentChanged(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: false,
        selectedGif: null,
      );
      final updatedState = initialState.copyWith(
        text: 'new text',
        isOverLimit: true,
        isValid: true,
      );
      expect(updatedState.text, 'new text');
      expect(updatedState.isOverLimit, true);
      expect(updatedState.isValid, true);
    });

    test('CommentSubmitting.copyWith should return the same instance when no arguments are provided', () {
      final state = CommentSubmitting(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final copiedState = state.copyWith();
      expect(copiedState, equals(state));
    });

    test('CommentSubmitting.copyWith should override values when arguments are provided', () {
      final state = CommentSubmitting(
        text: 'original',
        image: null,
        isOverLimit: false,
        isValid: false,
        selectedGif: null,
      );
      final updatedState = state.copyWith(text: 'Updated text');
      expect(updatedState.text, 'Updated text');
    });

    test('CommentSuccess.copyWith should return the same instance when no arguments are provided', () {
      final state = CommentSuccess(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final copiedState = state.copyWith();
      expect(copiedState, equals(state));
    });

    test('CommentSuccess.copyWith should override values when arguments are provided', () {
      final state = CommentSuccess(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      );
      final updatedState = state.copyWith(isValid: false);
      expect(updatedState.isValid, false);
    });

    test('CommentFailure.copyWith should return the same instance when no arguments are provided', () {
      final state = CommentFailure(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
        error: 'error',
      );
      final copiedState = state.copyWith();
      expect(copiedState, equals(state));
    });

    test('CommentFailure.copyWith should override values when arguments are provided', () {
      final state = CommentFailure(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
        error: 'original error',
      );
      final updatedState = state.copyWith(isValid: false, error: 'new error');
      expect(updatedState.isValid, false);
      expect((updatedState as CommentFailure).error, 'new error');
    });

    test('CommentChanged props and equality', () {
      final gif = GifModel(id: '1', tinyGifUrl: 'https://example.com/gif');
      final state1 = CommentChanged(
        text: 'test',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );
      final state2 = CommentChanged(
        text: 'test',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );
      expect(state1, equals(state2));
    });

    // Text change tests
    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged when CommentTextChanged is added with valid text',
      build: () => commentsCreateBloc,
      act: (bloc) => bloc.add(const CommentTextChanged('Hello world')),
      expect: () => [
        const CommentChanged(
          text: 'Hello world',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with isOverLimit true when text exceeds max length',
      build: () => commentsCreateBloc,
      act: (bloc) => bloc.add(CommentTextChanged('a' * 301)),
      expect: () => [
        CommentChanged(
          text: 'a' * 301,
          image: null,
          isOverLimit: true,
          isValid: false,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with isValid false when text is empty',
      build: () => commentsCreateBloc,
      act: (bloc) => bloc.add(const CommentTextChanged('')),
      expect: () => [
        const CommentChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with isValid true when text is at max length',
      build: () => commentsCreateBloc,
      act: (bloc) => bloc.add(CommentTextChanged('a' * 300)),
      expect: () => [
        CommentChanged(
          text: 'a' * 300,
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with isValid true when text is empty but image exists',
      build: () => commentsCreateBloc,
      seed: () => CommentChanged(
        text: 'test',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      ),
      act: (bloc) => bloc.add(const CommentTextChanged('')),
      expect: () => [
        CommentChanged(
          text: '',
          image: mockImage,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with isValid true when text is empty but gif exists',
      build: () => commentsCreateBloc,
      seed: () => CommentChanged(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: GifModel(id: '123', tinyGifUrl: 'https://example.com/gif'),
      ),
      act: (bloc) => bloc.add(const CommentTextChanged('')),
      expect: () => [
        CommentChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: GifModel(id: '123', tinyGifUrl: 'https://example.com/gif'),
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with null image when CommentImageChanged is added with null',
      build: () => commentsCreateBloc,
      seed: () => CommentChanged(
        text: 'test',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      ),
      act: (bloc) => bloc.add(const CommentImageChanged(null)),
      expect: () => [
        const CommentChanged(
          text: 'test',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged clearing gif when image is selected',
      build: () => commentsCreateBloc,
      seed: () => CommentChanged(
        text: 'test',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: GifModel(id: '123', tinyGifUrl: 'https://example.com/gif'),
      ),
      act: (bloc) => bloc.add(CommentImageChanged(mockImage)),
      expect: () => [
        CommentChanged(
          text: 'test',
          image: mockImage,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with isValid true when image is selected with empty text',
      build: () => commentsCreateBloc,
      act: (bloc) => bloc.add(CommentImageChanged(mockImage)),
      expect: () => [
        CommentChanged(
          text: '',
          image: mockImage,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with isValid true when image is selected with valid text',
      build: () => commentsCreateBloc,
      seed: () => const CommentChanged(
        text: 'Hello',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      ),
      act: (bloc) => bloc.add(CommentImageChanged(mockImage)),
      expect: () => [
        CommentChanged(
          text: 'Hello',
          image: mockImage,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with isValid false when image is removed and text is empty',
      build: () => commentsCreateBloc,
      seed: () => CommentChanged(
        text: '',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      ),
      act: (bloc) => bloc.add(const CommentImageChanged(null)),
      expect: () => [
        const CommentChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: null,
        ),
      ],
    );

    // GIF change tests
    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged when CommentGifChanged is added with valid gif',
      build: () => commentsCreateBloc,
      act: (bloc) {
        final gif = GifModel(id: '123', tinyGifUrl: 'https://example.com/gif');
        bloc.add(CommentGifChanged(gif));
      },
      expect: () => [
        CommentChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: GifModel(id: '123', tinyGifUrl: 'https://example.com/gif'),
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged clearing image when gif is selected',
      build: () => commentsCreateBloc,
      seed: () => CommentChanged(
        text: '',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      ),
      act: (bloc) {
        final gif = GifModel(id: '123', tinyGifUrl: 'https://example.com/gif');
        bloc.add(CommentGifChanged(gif));
      },
      expect: () => [
        CommentChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: GifModel(id: '123', tinyGifUrl: 'https://example.com/gif'),
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'does not emit when gif size exceeds 5MB',
      build: () => commentsCreateBloc,
      act: (bloc) {
        final gif = GifModel(
          id: '123',
          tinyGifUrl: 'https://example.com/gif',
          sizeBytes: 6 * 1024 * 1024, // 6MB
        );
        bloc.add(CommentGifChanged(gif));
      },
      expect: () => [],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged when gif size is within limit',
      build: () => commentsCreateBloc,
      act: (bloc) {
        final gif = GifModel(
          id: '123',
          tinyGifUrl: 'https://example.com/gif',
          sizeBytes: 4 * 1024 * 1024, // 4MB
        );
        bloc.add(CommentGifChanged(gif));
      },
      expect: () => [
        CommentChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: GifModel(
            id: '123',
            tinyGifUrl: 'https://example.com/gif',
            sizeBytes: 4 * 1024 * 1024,
          ),
        ),
      ],
    );

    // Reset tests
    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits CommentChanged with default values when CommentReset is added',
      build: () => commentsCreateBloc,
      seed: () => CommentChanged(
        text: 'Some text',
        image: mockImage,
        isOverLimit: false,
        isValid: true,
        selectedGif: GifModel(id: '123', tinyGifUrl: 'https://example.com/gif'),
      ),
      act: (bloc) => bloc.add(const CommentReset()),
      expect: () => [
        const CommentChanged(
          text: '',
          image: null,
          isOverLimit: false,
          isValid: false,
          selectedGif: null,
        ),
      ],
    );

    // Comment submission tests
    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits [CommentSubmitting, CommentSuccess] when comment is submitted successfully',
      build: () {
        when(() => mockRepository.sendComment(
              postId: any(named: 'postId'),
              text: any(named: 'text'),
              image: any(named: 'image'),
              selectedGif: any(named: 'selectedGif'),
            )).thenAnswer((_) async {});
        return commentsCreateBloc;
      },
      seed: () => const CommentChanged(
        text: 'Test comment',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      ),
      act: (bloc) => bloc.add(const CommentSubmitted(postId: 'post123')),
      expect: () => [
        const CommentSubmitting(
          text: 'Test comment',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
        const CommentSuccess(
          text: 'Test comment',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'emits [CommentSubmitting, CommentFailure] when comment submission fails',
      build: () {
        when(() => mockRepository.sendComment(
              postId: any(named: 'postId'),
              text: any(named: 'text'),
              image: any(named: 'image'),
              selectedGif: any(named: 'selectedGif'),
            )).thenThrow(Exception('Network error'));
        return commentsCreateBloc;
      },
      seed: () => const CommentChanged(
        text: 'Test comment',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      ),
      act: (bloc) => bloc.add(const CommentSubmitted(postId: 'post123')),
      expect: () => [
        const CommentSubmitting(
          text: 'Test comment',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
        const CommentFailure(
          text: 'Test comment',
          image: null,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
          error: 'Exception: Network error',
        ),
      ],
    );

    blocTest<CommentsCreateBloc, CommentsCreateState>(
      'uses event parameters when provided in CommentSubmitted',
      build: () {
        when(() => mockRepository.sendComment(
              postId: any(named: 'postId'),
              text: any(named: 'text'),
              image: any(named: 'image'),
              selectedGif: any(named: 'selectedGif'),
            )).thenAnswer((_) async {});
        return commentsCreateBloc;
      },
      seed: () => const CommentChanged(
        text: 'Original text',
        image: null,
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
      ),
      act: (bloc) => bloc.add(CommentSubmitted(
        postId: 'post123',
        text: 'Event text',
        image: mockImage,
      )),
      expect: () => [
        CommentSubmitting(
          text: 'Event text',
          image: mockImage,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
        CommentSuccess(
          text: 'Event text',
          image: mockImage,
          isOverLimit: false,
          isValid: true,
          selectedGif: null,
        ),
      ],
    );
  });

  group('CommentsCreateInitial', () {
    test('should initialize with default values', () {
      const initialState = CommentsCreateInitial();
      expect(initialState.text, '');
      expect(initialState.image, null);
      expect(initialState.isOverLimit, false);
      expect(initialState.isValid, false);
      expect(initialState.selectedGif, null);
    });

    test('copyWith should return the same instance when no arguments are provided', () {
      const initialState = CommentsCreateInitial();
      final copiedState = initialState.copyWith();
      expect(copiedState, equals(initialState));
    });

    test('copyWith should override values when arguments are provided', () {
      const initialState = CommentsCreateInitial();
      final updatedState = initialState.copyWith(
        text: 'Updated text',
        isValid: true,
      );
      expect(updatedState.text, 'Updated text');
      expect(updatedState.isValid, true);
    });

    test('copyWith should override image and selectedGif when provided', () {
      const initialState = CommentsCreateInitial();
      final mockImage = MockFile();
      final gif = GifModel(id: '123', tinyGifUrl: 'https://example.com/gif');
      final updatedState = initialState.copyWith(
        image: mockImage,
        selectedGif: gif,
      );
      expect(updatedState.image, mockImage);
      expect(updatedState.selectedGif, gif);
    });
  });
}