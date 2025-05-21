import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
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
      // Deberías también verificar selectedGif si es parte del estado inicial
      expect(initialState.selectedGif, null);
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

    // TEST CORREGIDO
    blocTest<CreatePostBloc, CreatePostState>(
      'should emit new state with selectedGif when GifSelected is added',
      build: () => createPostBloc,
      act: (bloc) {
        final gif = GifModel(id: '123', tinyGifUrl: 'https://media.tenor.com/sample.gif');
        bloc.add(GifSelected(gif));
      },
      expect: () => [
        isA<CreatePostChanged>() // El copyWith de CreatePostInitial devuelve CreatePostChanged
            .having((state) => state.text, 'text', '') // El texto no ha cambiado
            .having((state) => state.image, 'image', null) // La imagen no ha cambiado
            .having((state) => state.selectedGif?.id, 'selectedGif.id', '123') // Compara por propiedad
            .having((state) => state.selectedGif?.tinyGifUrl, 'selectedGif.tinyGifUrl', 'https://media.tenor.com/sample.gif') // Compara por propiedad
            .having((state) => state.isOverLimit, 'isOverLimit', false) // No ha cambiado
            .having((state) => state.isValid, 'isValid', false), // El BLoC no actualiza `isValid` en este evento
      ],
    );
    // FIN TEST CORREGIDO

    test('CreatePostChanged.copyWith returns new instance with updated values', () {
      final original = CreatePostChanged(
        text: 'Hello',
        isOverLimit: false,
        isValid: true,
        selectedGif: null,
        image: null, // Asegúrate de que todos los campos del estado estén aquí
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
        isValid: false, // La validez se recalcula en el BLoC, este test solo prueba copyWith
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
        image: null, // Asegúrate de que todos los campos del estado estén aquí
      );

      final copied = original.copyWith(); // sin argumentos

      expect(copied, equals(original)); // Necesita que GifModel sea Equatable si está en props
      expect(identical(copied, original), isFalse, reason: 'copyWith should return a new instance');
    });

    test('CreatePostChanged props and equality', () {
      final gif = GifModel(id: '1', tinyGifUrl: 'url');
      final imageFile = MockFile();
      final state1 = CreatePostChanged(
        text: 'text',
        image: imageFile, // Campo image añadido
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );
      final state2 = CreatePostChanged(
        text: 'text',
        image: imageFile, // Campo image añadido
        isOverLimit: false,
        isValid: true,
        selectedGif: gif,
      );

      // CORREGIDO: La lista de props debe coincidir con la definición en CreatePostState
      expect(state1.props, equals(['text', imageFile, false, true, gif]));
      // Esta comparación fallará si GifModel y File (o MockFile) no son Equatable
      // o si las instancias de gif/imageFile son diferentes y se comparan directamente.
      // Para que equals(state2) funcione, `gif` y `imageFile` deben ser "iguales"
      // o state2 debe usar las *mismas instancias* de gif e imageFile que state1.
      // Si GifModel y MockFile son Equatable, esto debería funcionar.
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
      seed: () => const CreatePostChanged( // Asegúrate que selectedGif esté en el seed si es relevante
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
        selectedGif: null, // Asegúrate que selectedGif esté en el seed
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
        selectedGif: null, // Asegúrate que selectedGif esté en el seed
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
        isValid: true, // Es true porque tiene imagen
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
        isValid: false, // Ya es false por isOverLimit
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
  });
}