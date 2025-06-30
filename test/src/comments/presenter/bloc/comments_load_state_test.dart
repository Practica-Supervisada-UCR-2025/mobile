import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/comments.dart';

final tCommentModel1 = CommentModel(
  id: '1',
  content: 'Este es un comentario de prueba.',
  username: 'testuser',
  userId: 'user-1',
  createdAt: DateTime.now(),
);

final tCommentModel2 = CommentModel(
  id: '2',
  content: 'Este es otro comentario.',
  username: 'testuser2',
  userId: 'user-2',
  createdAt: DateTime.now(),
);

CommentModel createTestComment({
  String id = '1',
  String content = 'Comentario de prueba',
  String username = 'testuser',
  String userId = 'default-user-id',
  DateTime? createdAt,
}) {
  return CommentModel(
    id: id,
    content: content,
    username: username,
    userId: userId,
    createdAt: createdAt ?? DateTime.now(),
  );
}

void main() {

  group('CommentsLoadInitial', () {
    test('soporta comparación por valor', () {
      expect(CommentsLoadInitial(), CommentsLoadInitial());
    });
  });

  group('CommentsLoading', () {
    test('soporta comparación por valor', () {
      expect(const CommentsLoading(isInitialFetch: true), const CommentsLoading(isInitialFetch: true));
      expect(const CommentsLoading(), const CommentsLoading());
    });

    test('las instancias con diferentes valores no se consideran iguales', () {
      expect(const CommentsLoading(isInitialFetch: true), isNot(const CommentsLoading(isInitialFetch: false)));
    });

    test('el valor por defecto de isInitialFetch es false', () {
      expect(const CommentsLoading().isInitialFetch, isFalse);
    });
  });

  group('CommentsLoaded', () {
    late DateTime initialTime;
    late CommentsLoaded initialState;

    setUp(() {
      initialTime = DateTime.now();
      initialState = CommentsLoaded(
        comments: [tCommentModel1],
        hasReachedEnd: false,
        currentIndex: 0,
        initialFetchTime: initialTime,
      );
    });
    late List<CommentModel> initialComments;

    setUp(() {
      initialTime = DateTime.now();
      initialComments = [createTestComment()];
      
      initialState = CommentsLoaded(
        comments: initialComments,
        hasReachedEnd: false,
        currentIndex: 0,
        initialFetchTime: initialTime,
      );
    });

    test('las instancias con diferentes valores no se consideran iguales', () {
      final differentState = CommentsLoaded(
        comments: initialComments,
        hasReachedEnd: true,
        currentIndex: 0,
        initialFetchTime: initialTime,
      );
      expect(initialState, isNot(equals(differentState)));
    });

    group('copyWith', () {
      test('actualiza hasReachedEnd cuando se proporciona un nuevo valor', () {
        final newState = initialState.copyWith(hasReachedEnd: true);

        expect(newState.hasReachedEnd, true);

        expect(newState.comments, initialState.comments);
        expect(newState.currentIndex, initialState.currentIndex);
        expect(newState.initialFetchTime, initialState.initialFetchTime);
        
        expect(newState, isNot(equals(initialState)));
      });

      test('mantiene el valor original de hasReachedEnd si no se proporciona uno nuevo', () {
        final newState = initialState.copyWith(currentIndex: 5);

        expect(newState.hasReachedEnd, initialState.hasReachedEnd);
        expect(newState.hasReachedEnd, false);

        expect(newState.currentIndex, 5);
      });

      test('devuelve una instancia idéntica en valor si no se proporcionan argumentos', () {
        final newState = initialState.copyWith();
        
        expect(identical(newState, initialState), isFalse);
        
        expect(newState, initialState);
      });

      test('actualiza múltiples propiedades correctamente', () {
        final newTime = DateTime.now().add(const Duration(seconds: 10));
        final List<CommentModel> newComments = []
          ..add(createTestComment(id: '2', content: 'Nuevo comentario 1'))
          ..add(createTestComment(id: '3', content: 'Nuevo comentario 2'));

        final newState = initialState.copyWith(
          comments: newComments,
          hasReachedEnd: true,
          initialFetchTime: newTime,
        );

        expect(newState.comments, newComments);
        expect(newState.hasReachedEnd, true);
        expect(newState.initialFetchTime, newTime);

        expect(newState.currentIndex, initialState.currentIndex);
      });
    });
  });

  group('CommentsError', () {
    const errorMessage = 'Ocurrió un error inesperado';

    test('soporta comparación por valor', () {
      expect(const CommentsError(message: errorMessage), const CommentsError(message: errorMessage));
    });

    test('las instancias con diferentes valores no se consideran iguales', () {
      expect(const CommentsError(message: errorMessage), isNot(const CommentsError(message: 'Otro error')));
    });

    test('asigna el mensaje correctamente', () {
      expect(const CommentsError(message: errorMessage).message, errorMessage);
    });
  });

  group('CommentsLoadEvent', () {
    group('FetchInitialComments', () {
      test('soporta comparación por valor', () {
        expect(FetchInitialComments(), FetchInitialComments());
      });
    });

    group('FetchMoreComments', () {
      test('soporta comparación por valor', () {
        expect(FetchMoreComments(), FetchMoreComments());
      });
    });
  });
}