import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/comments.dart';

void main() {
  final tCommentModel1 = CommentModel(
    id: '1',
    content: 'Comentario 1',
    username: 'user1',
    createdAt: DateTime.parse('2023-01-01T12:00:00.000Z'),
    profileImageUrl: 'https://example.com/user1.jpg',
    attachmentUrl: null,
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
          comments: [
            CommentModel(
              id: '1',
              content: 'Comentario 1',
              username: 'user1',
              createdAt: DateTime.parse('2023-01-01T12:00:00.000Z'),
              profileImageUrl: 'https://example.com/user1.jpg',
              attachmentUrl: null,
            ),
          ],
          totalItems: 5,
          currentIndex: 0,
        ),
      );
    });

    group('fromJson', () {
      test('debe devolver un CommentsResponse válido desde un JSON completo', () {
        final Map<String, dynamic> jsonMap = {
          'comments': [
            {
              'id': '1',
              'content': 'Comentario 1',
              'username': 'user1',
              'created_at': '2023-01-01T12:00:00.000Z',
              'profile_image_url': 'https://example.com/user1.jpg',
              'attachment_url': null,
            }
          ],
          'metadata': {'totalItems': 5, 'currentIndex': 0}
        };

        final result = CommentsResponse.fromJson(jsonMap);
        expect(result, tCommentsResponse);
      });
    });
  });
}