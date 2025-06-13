import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/comments.dart';

void main() {
  final tCommentModel1 = CommentModel(
    id: '1',
    content: 'Comentario 1',
    username: 'user1',
    createdAt: DateTime.parse('2023-01-01T12:00:00.000Z'),
  );

  final tCommentsResponse = CommentsResponse(
    comments: [tCommentModel1],
    totalItems: 5,
    currentIndex: 0,
  );

  group('CommentsResponse', () {
    test('la instancia se puede crear con los valores correctos', () {
      expect(tCommentsResponse.comments, [tCommentModel1]);
      expect(tCommentsResponse.totalItems, 5);
      expect(tCommentsResponse.currentIndex, 0);
    });

    test('soporta comparación por valor (Equatable)', () {
      expect(
        tCommentsResponse,
        CommentsResponse(
          comments: [tCommentModel1],
          totalItems: 5,
          currentIndex: 0,
        ),
      );
    });

     group('fromJson', () {
      test(
          'debe devolver un CommentsResponse válido con una lista de comentarios vacía',
          () {
        final Map<String, dynamic> jsonMapWithEmptyList = {
          'comments': [],
          'metadata': {'totalItems': 0, 'currentIndex': 0}
        };

        final result = CommentsResponse.fromJson(jsonMapWithEmptyList);

        expect(result.comments, isEmpty);
        expect(result.totalItems, 0);
        expect(result.currentIndex, 0);
      });

      test(
          'debe lanzar una excepción si falta una clave DENTRO de "metadata"',
          () {
        final Map<String, dynamic> invalidJson = {
          'comments': [],
          'metadata': {
            'currentIndex': 0,
          }
        };

        expect(() => CommentsResponse.fromJson(invalidJson),
            throwsA(isA<TypeError>()));
      });
    });
  });
}