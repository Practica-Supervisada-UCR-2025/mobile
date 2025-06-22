import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/comments.dart';

void main() {
  group('CommentsLoadState', () {
    final comment = CommentModel(
      id: '1',
      content: 'hola',
      username: 'usuario',
      createdAt: DateTime(2023, 1, 1),
      profileImageUrl: 'url1',
      attachmentUrl: 'url2',
    );

    test('CommentsLoadInitial props está vacío', () {
      expect(const CommentsLoadInitial().props, []);
    });

    test('CommentsLoading props incluye isInitialFetch', () {
      const loading = CommentsLoading(isInitialFetch: true);
      expect(loading.props, [true]);
    });

    test('CommentsLoaded props y copyWith funcionan con nuevos campos', () {
      const loaded = CommentsLoaded(
        comments: [],
        hasReachedEnd: false,
        currentIndex: 0,
      );

      final copied = loaded.copyWith(
        comments: [comment],
        hasReachedEnd: true,
        currentIndex: 1,
      );

      expect(copied.comments.length, 1);
      expect(copied.comments.first, comment);
      expect(copied.hasReachedEnd, true);
      expect(copied.currentIndex, 1);
    });

    test('CommentsError props contiene mensaje', () {
      const error = CommentsError(message: 'Fallo');
      expect(error.props, ['Fallo']);
    });
  });

  group('CommentsLoaded.copyWith', () {
    final comment1 = CommentModel(
      id: '1',
      content: 'Prueba',
      username: 'usuario',
      createdAt: DateTime(2023, 1, 1),
      profileImageUrl: 'url1',
      attachmentUrl: 'url2',
    );

    test('retorna una nueva instancia con campos actualizados', () {
      final original = CommentsLoaded(
        comments: [],
        hasReachedEnd: false,
        currentIndex: 0,
      );

      final updated = original.copyWith(
        comments: [comment1],
        hasReachedEnd: true,
        currentIndex: 5,
      );

      expect(updated.comments, [comment1]);
      expect(updated.hasReachedEnd, true);
      expect(updated.currentIndex, 5);
    });

    test('retorna una instancia idéntica si no se pasa ningún parámetro', () {
      final original = CommentsLoaded(
        comments: [comment1],
        hasReachedEnd: false,
        currentIndex: 1,
      );

      final copied = original.copyWith();

      expect(copied, original);
    });

    test('props incluye todos los campos', () {
      final state = CommentsLoaded(
        comments: [comment1],
        hasReachedEnd: false,
        currentIndex: 1,
      );

      expect(state.props, [
        [comment1],
        false,
        1,
      ]);
    });
  });
}
