import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile/src/comments/comments.dart';

class MockCommentsRepository extends Mock implements CommentsRepository {}

void main() {
  late CommentsRepository mockRepository;
  late String postId;

  final comment1 = CommentModel(
    id: '1',
    username: 'user1',
    content: 'Comentario 1',
    createdAt: DateTime(2023, 1, 1),
  );
  final comment2 = CommentModel(
    id: '2',
    username: 'user2',
    content: 'Comentario 2',
    createdAt: DateTime(2023, 1, 2),
  );
  final comment3 = CommentModel(
    id: '3',
    username: 'user3',
    content: 'Comentario 3',
    createdAt: DateTime(2023, 1, 3),
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2023));
  });

  setUp(() {
    EquatableConfig.stringify = true;
    mockRepository = MockCommentsRepository();
    postId = 'post-123';
  });

  group('CommentsLoadBloc', () {
    test('estado inicial es CommentsLoadInitial', () {
      expect(
        CommentsLoadBloc(repository: mockRepository, postId: postId).state,
        const CommentsLoadInitial(),
      );
    });

    group('FetchInitialComments', () {
      final response = CommentsResponse(
        comments: [comment1, comment2],
        totalItems: 3,
        currentIndex: 0,
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'emite [CommentsLoaded] con comentarios cargados',
        setUp: () {
          when(() => mockRepository.fetchComments(
                postId: any(named: 'postId'),
                startTime: any(named: 'startTime'),
              )).thenAnswer((_) async => response);
        },
        build: () => CommentsLoadBloc(repository: mockRepository, postId: postId),
        act: (bloc) => bloc.add(FetchInitialComments()),
        expect: () => <CommentsLoadState>[
          CommentsLoaded(
            comments: response.comments,
            hasReachedEnd: false,
            currentIndex: response.currentIndex,
          ),
        ],
        verify: (_) {
          verify(() => mockRepository.fetchComments(
            postId: postId,
            startTime: DateTime.fromMillisecondsSinceEpoch(0),
          )).called(1);
        },
      );
      
      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'emite [CommentsLoaded] con lista vacía cuando no hay comentarios',
        setUp: () {
          when(() => mockRepository.fetchComments(
                postId: any(named: 'postId'),
                startTime: any(named: 'startTime'),
              )).thenAnswer((_) async => CommentsResponse(
                comments: [],
                totalItems: 0,
                currentIndex: 0,
              ));
        },
        build: () => CommentsLoadBloc(repository: mockRepository, postId: postId),
        act: (bloc) => bloc.add(FetchInitialComments()),
        expect: () => <CommentsLoadState>[
          const CommentsLoaded(
            comments: [],
            hasReachedEnd: true, 
            currentIndex: 0,
          ),
        ],
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'emite CommentsError si fetch lanza excepción',
        setUp: () {
          when(() => mockRepository.fetchComments(
            postId: any(named: 'postId'),
            startTime: any(named: 'startTime'),
          )).thenThrow(Exception('Falló'));
        },
        build: () => CommentsLoadBloc(repository: mockRepository, postId: postId),
        act: (bloc) => bloc.add(FetchInitialComments()),
        expect: () => <CommentsLoadState>[
          const CommentsError(message: 'Exception: Falló'),
        ],
      );
    });

    group('FetchMoreComments', () {
      final initialComments = [comment1, comment2];
      final loadedState = CommentsLoaded(
        comments: initialComments,
        hasReachedEnd: false,
        currentIndex: 0,
      );
      final response = CommentsResponse(
        comments: [comment3],
        totalItems: 3,
        currentIndex: 1,
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'agrega más comentarios al final',
        setUp: () {
          when(() => mockRepository.fetchComments(
            postId: postId,
            startTime: comment2.createdAt,
          )).thenAnswer((_) async => response);
        },
        build: () => CommentsLoadBloc(repository: mockRepository, postId: postId),
        seed: () => loadedState,
        act: (bloc) => bloc.add(FetchMoreComments()),
        expect: () => <CommentsLoadState>[
          CommentsLoaded(
            comments: [...initialComments, ...response.comments],
            hasReachedEnd: true,
            currentIndex: response.currentIndex,
          ),
        ],
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'no hace nada si ya hasReachedEnd',
        build: () => CommentsLoadBloc(repository: mockRepository, postId: postId),
        seed: () => const CommentsLoaded(comments: [], hasReachedEnd: true, currentIndex: 0),
        act: (bloc) => bloc.add(FetchMoreComments()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockRepository.fetchComments(
            postId: any(named: 'postId'),
            startTime: any(named: 'startTime'),
          ));
        },
      );
    });
  });

  group('CommentsLoadBloc - caso sin comentarios', () {
    blocTest<CommentsLoadBloc, CommentsLoadState>(
      'emite [CommentsLoaded] con lista vacía cuando no hay comentarios',
      setUp: () {
        when(() => mockRepository.fetchComments(
              postId: postId,
              startTime: DateTime.fromMillisecondsSinceEpoch(0),
            )).thenAnswer(
          (_) async => CommentsResponse(
            comments: [],
            totalItems: 0,
            currentIndex: 0,
          ),
        );
      },
      build: () => CommentsLoadBloc(
        repository: mockRepository,
        postId: postId,
      ),
      act: (bloc) => bloc.add(FetchInitialComments()),
      expect: () => [
        const CommentsLoaded(
          comments: [],
          hasReachedEnd: true,
          currentIndex: 0,
        ),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchComments(
              postId: postId,
              startTime: DateTime.fromMillisecondsSinceEpoch(0),
            )).called(1);
      },
    );
  });
}
