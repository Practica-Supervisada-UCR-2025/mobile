import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:equatable/equatable.dart';

// Asegúrate de que las rutas de importación sean correctas para tu proyecto.
import 'package:mobile/src/comments/comments.dart';

// --- Mocks y Clases de Ayuda ---

// Mock para el repositorio de comentarios.
class MockCommentsRepository extends Mock implements CommentsRepository {}

// Es una buena práctica registrar valores de fallback para tipos complejos.
class FakeDateTime extends Fake implements DateTime {}

void main() {
  // --- Declaraciones y Setup ---

  late CommentsRepository mockRepository;
  late CommentsLoadBloc commentsLoadBloc;
  const postId = 'post-id-123';
  const commentsPerPage = 5; // Coincide con la constante en tu BLoC

  // Datos de prueba para los comentarios
  final comment1 = CommentModel(
    id: '1',
    username: 'user1',
    content: 'Primer comentario',
    createdAt: DateTime(2025, 6, 15, 10, 0, 0),
  );
  final comment2 = CommentModel(
    id: '2',
    username: 'user2',
    content: 'Segundo comentario',
    createdAt: DateTime(2025, 6, 15, 10, 5, 0),
  );
  // Lista de comentarios para la primera página
  final firstPageComments = [comment1, comment2];

  final comment3 = CommentModel(
    id: '3',
    username: 'user3',
    content: 'Tercer comentario',
    createdAt: DateTime(2025, 6, 15, 10, 10, 0),
  );
  // Lista de comentarios para la segunda página
  final secondPageComments = [comment3];

  setUpAll(() {
    // Registra el fallback para que Mocktail sepa cómo manejar DateTime en `any(named: ...)`
    registerFallbackValue(FakeDateTime());
  });

  setUp(() {
    // Configura Equatable para que muestre strings legibles en los errores
    EquatableConfig.stringify = true;
    mockRepository = MockCommentsRepository();
    commentsLoadBloc = CommentsLoadBloc(
      repository: mockRepository,
      postId: postId,
    );
  });

  tearDown(() {
    commentsLoadBloc.close();
  });

  // --- Pruebas ---

  group('CommentsLoadBloc', () {
    test('el estado inicial debe ser CommentsLoadInitial', () {
      expect(commentsLoadBloc.state, const CommentsLoadInitial());
    });

    group('FetchInitialComments Event', () {
      final initialResponse = CommentsResponse(
        comments: firstPageComments,
        totalItems: 3, // Hay más de los que se cargaron
        currentIndex: 0,
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'debe emitir [Loading, Loaded] cuando fetchComments tiene éxito',
        setUp: () {
          // Configura el mock para devolver una respuesta exitosa
          when(() => mockRepository.fetchComments(
                postId: any(named: 'postId'),
                startTime: any(named: 'startTime'),
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => initialResponse);
        },
        build: () => commentsLoadBloc,
        act: (bloc) => bloc.add(FetchInitialComments()),
        expect: () => <CommentsLoadState>[
          const CommentsLoading(isInitialFetch: true),
          CommentsLoaded(
            comments: initialResponse.comments,
            hasReachedEnd: false, // 2 de 3, no ha llegado al final
            currentIndex: initialResponse.currentIndex,
          ),
        ],
        verify: (_) {
          // Verifica que el método del repositorio fue llamado con los parámetros correctos
          verify(() => mockRepository.fetchComments(
                postId: postId,
                startTime: DateTime.fromMillisecondsSinceEpoch(0),
                limit: commentsPerPage,
              )).called(1);
        },
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'debe emitir [Loading, Loaded] con hasReachedEnd=true si se cargan todos los items',
        setUp: () {
          final finalResponse = CommentsResponse(
            comments: firstPageComments,
            totalItems: 2, // Total es igual a la cantidad cargada
            currentIndex: 0,
          );
          when(() => mockRepository.fetchComments(
                postId: any(named: 'postId'),
                startTime: any(named: 'startTime'),
                limit: any(named: 'limit'),
              )).thenAnswer((_) async => finalResponse);
        },
        build: () => commentsLoadBloc,
        act: (bloc) => bloc.add(FetchInitialComments()),
        expect: () => <CommentsLoadState>[
          const CommentsLoading(isInitialFetch: true),
          CommentsLoaded(
            comments: firstPageComments,
            hasReachedEnd: true, // 2 de 2, sí ha llegado al final
            currentIndex: 0,
          ),
        ],
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'debe emitir [Loading, Error] cuando fetchComments falla',
        setUp: () {
          // Configura el mock para que lance una excepción
          when(() => mockRepository.fetchComments(
                postId: any(named: 'postId'),
                startTime: any(named: 'startTime'),
                limit: any(named: 'limit'),
              )).thenThrow(Exception('Error de red'));
        },
        build: () => commentsLoadBloc,
        act: (bloc) => bloc.add(FetchInitialComments()),
        expect: () => <CommentsLoadState>[
          const CommentsLoading(isInitialFetch: true),
          const CommentsError(message: 'Exception: Error de red'),
        ],
      );
    });

    group('FetchMoreComments Event', () {
      // Estado inicial para las pruebas de paginación
      final initialState = CommentsLoaded(
        comments: firstPageComments,
        hasReachedEnd: false,
        currentIndex: 0,
      );

      final secondResponse = CommentsResponse(
        comments: secondPageComments,
        totalItems: 3, // 2 (iniciales) + 1 (nuevo) = 3
        currentIndex: 1,
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'debe emitir [Loaded] con la lista de comentarios actualizada',
        setUp: () {
          when(() => mockRepository.fetchComments(
                postId: postId,
                startTime: firstPageComments.last.createdAt, // startTime es el último comentario
                limit: commentsPerPage,
              )).thenAnswer((_) async => secondResponse);
        },
        build: () => commentsLoadBloc,
        seed: () => initialState, // Inicia el BLoC con un estado ya cargado
        act: (bloc) => bloc.add(FetchMoreComments()),
        expect: () => <CommentsLoadState>[
          CommentsLoaded(
            comments: [...firstPageComments, ...secondPageComments], // Lista combinada
            hasReachedEnd: true, // 3 de 3, se alcanzó el final
            currentIndex: secondResponse.currentIndex,
          ),
        ],
        verify: (_) {
          // Verifica que la llamada para paginar fue correcta
          verify(() => mockRepository.fetchComments(
                postId: postId,
                startTime: firstPageComments.last.createdAt,
                limit: commentsPerPage,
              )).called(1);
        },
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'no debe emitir estados si hasReachedEnd ya es true',
        build: () => commentsLoadBloc,
        // Inicia el BLoC con un estado que ya alcanzó el final
        seed: () => CommentsLoaded(
          comments: firstPageComments,
          hasReachedEnd: true,
          currentIndex: 0,
        ),
        act: (bloc) => bloc.add(FetchMoreComments()),
        expect: () => <CommentsLoadState>[], // No se esperan nuevos estados
        verify: (_) {
          // Verifica que NUNCA se llamó al repositorio
          verifyNever(() => mockRepository.fetchComments(
              postId: any(named: 'postId'),
              startTime: any(named: 'startTime'),
              limit: any(named: 'limit')));
        },
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
          'debe emitir [Error] si la paginación falla',
          setUp: () {
            when(() => mockRepository.fetchComments(
                  postId: any(named: 'postId'),
                  startTime: any(named: 'startTime'),
                  limit: any(named: 'limit'),
                )).thenThrow(Exception('Error de paginación'));
          },
          build: () => commentsLoadBloc,
          seed: () => initialState, // Inicia con un estado válido para paginar
          act: (bloc) => bloc.add(FetchMoreComments()),
          expect: () => <CommentsLoadState>[
                const CommentsError(message: 'Exception: Error de paginación'),
              ]);
    });
  });
}