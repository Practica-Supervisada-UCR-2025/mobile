// test/src/comments/presenter/bloc/comments_load_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mocktail/mocktail.dart';

// Clases Mock y Fake
class MockCommentsRepository extends Mock implements CommentsRepository {}
class FakeDateTime extends Fake implements DateTime {}

void main() {
  // --- Configuración ---
  late MockCommentsRepository mockRepository;
  late CommentsLoadBloc commentsLoadBloc;
  const postId = 'test-post-id';
  final tInitialFetchTime = DateTime.fromMillisecondsSinceEpoch(0);

  // Función de ayuda para crear comentarios de prueba
  List<CommentModel> generateComments(int count, {int startId = 0}) {
    return List.generate(count, (i) {
      final id = startId + i;
      return CommentModel(
        id: 'comment-$id',
        content: 'Test comment $id',
        username: 'user-$id',
        createdAt: DateTime.now().subtract(Duration(minutes: id)),
      );
    });
  }

  setUpAll(() {
    // Registrar el fallback para cualquier DateTime que se pase como argumento
    registerFallbackValue(FakeDateTime());
  });

  setUp(() {
    mockRepository = MockCommentsRepository();
    commentsLoadBloc = CommentsLoadBloc(repository: mockRepository, postId: postId);
  });

  tearDown(() {
    commentsLoadBloc.close();
  });

  // --- Pruebas ---
  test('El estado inicial debe ser CommentsLoadInitial', () {
    expect(commentsLoadBloc.state, const CommentsLoadInitial());
  });

  group('FetchInitialComments', () {
    final mockComments = generateComments(5);
    final mockResponse = CommentsResponse(comments: mockComments, totalItems: 10, currentIndex: 0);

    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'Debe emitir [CommentsLoading, CommentsLoaded] cuando el repositorio devuelve datos.',
      build: () {
        when(() => mockRepository.fetchComments(
          postId: any(named: 'postId'),
          startTime: any(named: 'startTime'),
          limit: any(named: 'limit'),
          index: any(named: 'index'),
        )).thenAnswer((_) async => mockResponse);
        return commentsLoadBloc;
      },
      act: (bloc) => bloc.add(FetchInitialComments()),
      // CORRECCIÓN: Ahora esperamos los estados correctos
      expect: () => <CommentsLoadState>[
        const CommentsLoading(isInitialFetch: true),
        CommentsLoaded(
          comments: mockComments,
          hasReachedEnd: false, // 5 de 10
          currentIndex: 0,
          initialFetchTime: tInitialFetchTime,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchComments(
          postId: postId,
          startTime: tInitialFetchTime,
          limit: 5,
          index: 0,
        )).called(1);
      },
    );

    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'Debe emitir [CommentsLoading, CommentsLoaded] con hasReachedEnd=true si el repositorio devuelve una lista vacía.',
      build: () {
        when(() => mockRepository.fetchComments(
          postId: any(named: 'postId'),
          startTime: any(named: 'startTime'),
          limit: any(named: 'limit'),
          index: any(named: 'index'),
        )).thenAnswer((_) async => const CommentsResponse(comments: [], totalItems: 0, currentIndex: 0));
        return commentsLoadBloc;
      },
      act: (bloc) => bloc.add(FetchInitialComments()),
      expect: () => <CommentsLoadState>[
        const CommentsLoading(isInitialFetch: true),
        CommentsLoaded(
          comments: const [],
          hasReachedEnd: true,
          currentIndex: 0,
          initialFetchTime: tInitialFetchTime,
        ),
      ],
    );

    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'Debe emitir [CommentsLoading, CommentsError] cuando el repositorio lanza una excepción.',
      build: () {
        when(() => mockRepository.fetchComments(
          limit: any(named: 'limit'), index: any(named: 'index'), startTime: any(named: 'startTime'), postId: any(named: 'postId'),
        )).thenThrow(Exception('Network Error'));
        return commentsLoadBloc;
      },
      act: (bloc) => bloc.add(FetchInitialComments()),
      expect: () => <CommentsLoadState>[
        const CommentsLoading(isInitialFetch: true),
        const CommentsError(message: 'Exception: Network Error'),
      ],
    );
  });

  group('FetchMoreComments', () {
    final initialComments = generateComments(5, startId: 0);
    final moreComments = generateComments(5, startId: 5);
    final initialState = CommentsLoaded(
      comments: initialComments,
      hasReachedEnd: false,
      currentIndex: 0,
      initialFetchTime: tInitialFetchTime,
    );

    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'Debe emitir [CommentsLoaded] con la lista de comentarios concatenada.',
      setUp: () {
        when(() => mockRepository.fetchComments(
          postId: postId, startTime: tInitialFetchTime, limit: 5, index: 1,
        )).thenAnswer((_) async => CommentsResponse(comments: moreComments, totalItems: 15, currentIndex: 1));
      },
      build: () => commentsLoadBloc,
      seed: () => initialState,
      act: (bloc) => bloc.add(FetchMoreComments()),
      // CORRECCIÓN: Esperamos un único estado `CommentsLoaded` con la lista actualizada.
      expect: () => <CommentsLoadState>[
        CommentsLoaded(
          comments: [...initialComments, ...moreComments],
          hasReachedEnd: false, // 10 de 15
          currentIndex: 1,
          initialFetchTime: tInitialFetchTime,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchComments(
          postId: postId, startTime: tInitialFetchTime, limit: 5, index: 1,
        )).called(1);
      },
    );

    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'Debe emitir [CommentsLoaded] con hasReachedEnd=true cuando se cargan todos los items.',
      setUp: () {
        when(() => mockRepository.fetchComments(
          postId: postId, startTime: tInitialFetchTime, limit: 5, index: 1,
        )).thenAnswer((_) async => CommentsResponse(comments: moreComments, totalItems: 10, currentIndex: 1));
      },
      build: () => commentsLoadBloc,
      seed: () => initialState,
      act: (bloc) => bloc.add(FetchMoreComments()),
      // CORRECIÓN: Esperamos el estado final con hasReachedEnd = true
      expect: () => <CommentsLoadState>[
        CommentsLoaded(
          comments: [...initialComments, ...moreComments],
          hasReachedEnd: true, // 10 de 10
          currentIndex: 1,
          initialFetchTime: tInitialFetchTime,
        ),
      ],
    );

    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'Debe emitir [CommentsLoaded] con hasReachedEnd=true cuando el repositorio devuelve una lista vacía.',
      setUp: () {
        when(() => mockRepository.fetchComments(
          postId: postId, startTime: tInitialFetchTime, limit: 5, index: 1,
        )).thenAnswer((_) async => const CommentsResponse(comments: [], totalItems: 10, currentIndex: 1));
      },
      build: () => commentsLoadBloc,
      seed: () => initialState,
      act: (bloc) => bloc.add(FetchMoreComments()),
      // CORRECCIÓN: Esperamos el estado con hasReachedEnd = true. La lista de comentarios no cambia.
      expect: () => <CommentsLoadState>[
        initialState.copyWith(hasReachedEnd: true),
      ],
    );

    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'Debe emitir [CommentsError] cuando el repositorio lanza una excepción en paginación.',
      setUp: () {
        when(() => mockRepository.fetchComments(
          limit: any(named: 'limit'), index: any(named: 'index'), startTime: any(named: 'startTime'), postId: any(named: 'postId'),
        )).thenThrow(Exception('Failed to fetch more'));
      },
      build: () => commentsLoadBloc,
      seed: () => initialState,
      act: (bloc) => bloc.add(FetchMoreComments()),
      expect: () => <CommentsLoadState>[
        const CommentsError(message: 'Exception: Failed to fetch more'),
      ],
    );

    // Estos dos últimos tests estaban correctos, ya que esperaban una lista vacía [] y nada se emitía.
    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'No debe emitir estados si hasReachedEnd es true.',
      build: () => commentsLoadBloc,
      seed: () => initialState.copyWith(hasReachedEnd: true),
      act: (bloc) => bloc.add(FetchMoreComments()),
      expect: () => <CommentsLoadState>[],
      verify: (_) {
        verifyNever(() => mockRepository.fetchComments(
          limit: any(named: 'limit'), index: any(named: 'index'), startTime: any(named: 'startTime'), postId: any(named: 'postId'),
        ));
      },
    );

    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'No debe emitir estados si el estado actual no es CommentsLoaded.',
      build: () => commentsLoadBloc,
      seed: () => const CommentsLoading(),
      act: (bloc) => bloc.add(FetchMoreComments()),
      expect: () => <CommentsLoadState>[],
      verify: (_) {
        verifyNever(() => mockRepository.fetchComments(
          limit: any(named: 'limit'), index: any(named: 'index'), startTime: any(named: 'startTime'), postId: any(named: 'postId'),
        ));
      },
    );
  });
}