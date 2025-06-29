import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:equatable/equatable.dart';

import 'package:mobile/src/comments/comments.dart';

class MockCommentsRepository extends Mock implements CommentsRepository {}

class FakeDateTime extends Fake implements DateTime {}

void main() {

  late CommentsRepository mockRepository;
  late CommentsLoadBloc commentsLoadBloc;
  const postId = 'post-id-123';
  const commentsPerPage = 5; 

  final comment1 = CommentModel(
    id: '1',
    username: 'user1',
    userId: '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
    content: 'Primer comentario',
    createdAt: DateTime(2025, 6, 15, 10, 0, 0),
  );
  final comment2 = CommentModel(
    id: '2',
    username: 'user2',
    userId: '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
    content: 'Segundo comentario',
    createdAt: DateTime(2025, 6, 15, 10, 5, 0),
  );
  final firstPageComments = [comment1, comment2];

  final comment3 = CommentModel(
    id: '3',
    username: 'user3',
    userId: '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
    content: 'Tercer comentario',
    createdAt: DateTime(2025, 6, 15, 10, 10, 0),
  );
  final secondPageComments = [comment3];

  setUpAll(() {
    registerFallbackValue(FakeDateTime());
  });

  setUp(() {
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

  group('CommentsLoadBloc', () {
    test('el estado inicial debe ser CommentsLoadInitial', () {
      expect(commentsLoadBloc.state, const CommentsLoadInitial());
    });

    group('FetchInitialComments Event', () {
      final initialResponse = CommentsResponse(
        comments: firstPageComments,
        totalItems: 3, 
        currentIndex: 0,
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'debe emitir [Loading, Loaded] cuando fetchComments tiene éxito',
        setUp: () {
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
            hasReachedEnd: false, 
            currentIndex: initialResponse.currentIndex,
          ),
        ],
        verify: (_) {
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
            totalItems: 2, 
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
            hasReachedEnd: true,
            currentIndex: 0,
          ),
        ],
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'debe emitir [Loading, Error] cuando fetchComments falla',
        setUp: () {
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
      final initialState = CommentsLoaded(
        comments: firstPageComments,
        hasReachedEnd: false,
        currentIndex: 0,
      );

      final secondResponse = CommentsResponse(
        comments: secondPageComments,
        totalItems: 3, 
        currentIndex: 1,
      );

      blocTest<CommentsLoadBloc, CommentsLoadState>(
        'debe emitir [Loaded] con la lista de comentarios actualizada',
        setUp: () {
          when(() => mockRepository.fetchComments(
                postId: postId,
                startTime: firstPageComments.last.createdAt,
                limit: commentsPerPage,
              )).thenAnswer((_) async => secondResponse);
        },
        build: () => commentsLoadBloc,
        seed: () => initialState,
        act: (bloc) => bloc.add(FetchMoreComments()),
        expect: () => <CommentsLoadState>[
          CommentsLoaded(
            comments: [...firstPageComments, ...secondPageComments], 
            hasReachedEnd: true,
            currentIndex: secondResponse.currentIndex,
          ),
        ],
        verify: (_) {
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
        seed: () => CommentsLoaded(
          comments: firstPageComments,
          hasReachedEnd: true,
          currentIndex: 0,
        ),
        act: (bloc) => bloc.add(FetchMoreComments()),
        expect: () => <CommentsLoadState>[], 
        verify: (_) {
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
          seed: () => initialState, 
          act: (bloc) => bloc.add(FetchMoreComments()),
          expect: () => <CommentsLoadState>[
                const CommentsError(message: 'Exception: Error de paginación'),
              ]);
    });
  });
}