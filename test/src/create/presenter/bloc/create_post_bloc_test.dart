import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/create/presenter/bloc/create_post_bloc.dart';

void main() {
  late CreatePostBloc createPostBloc;

  setUp(() {
    createPostBloc = CreatePostBloc();
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

    test('CreatePostInitial should have default values', () {
      final initialState = createPostBloc.state;

      expect(initialState, isA<CreatePostInitial>());
      expect(initialState.text, '');
      expect(initialState.isOverLimit, false);
      expect(initialState.isValid, false);
    });

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

    blocTest<CreatePostBloc, CreatePostState>(
      'should emit new state with selectedGif when GifSelected is added',
      build: () => createPostBloc,
      act: (bloc) {
        final gif = GifModel(id: '123', tinyGifUrl: 'https://media.tenor.com/sample.gif');
        bloc.add(GifSelected(gif));
      },
      expect: () => [
        isA<CreatePostChanged>()
            .having((state) => state.selectedGif?.id, 'selectedGif.id', '123')
            .having((state) => state.selectedGif?.tinyGifUrl, 'selectedGif.url', 'https://media.tenor.com/sample.gif'),
      ],
    );

    test('CreatePostChanged.copyWith returns new instance with updated values', () {
      final original = CreatePostChanged(
        text: 'Hello',
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
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
      );

      expect(newState, isA<CreatePostChanged>());
      expect(newState.text, 'Copied');
      expect(newState.isOverLimit, true);
      expect(newState.isValid, false);
      expect(newState.selectedGif?.id, '42');
    });

    test('CreatePostChanged.copyWith without arguments returns identical state', () {
      final gif = GifModel(id: 'abc', tinyGifUrl: 'https://tenor.com/abc.gif');

      final original = CreatePostChanged(
        text: 'unchanged',
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );

      final copied = original.copyWith(); // sin argumentos

      expect(copied, equals(original));
      expect(identical(copied, original), isFalse, reason: 'copyWith should return a new instance');
    });

    test('CreatePostChanged props and equality', () {
      final gif = GifModel(id: '1', tinyGifUrl: 'url');
      final state1 = CreatePostChanged(
        text: 'text',
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );
      final state2 = CreatePostChanged(
        text: 'text',
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );

      expect(state1.props, ['text', false, true, gif]);
      expect(state1, equals(state2));
    });
  });
}