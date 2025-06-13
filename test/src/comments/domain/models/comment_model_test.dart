import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/domain/models/comment_model.dart';

void main() {
  group('CommentModel', () {
    final tDateTime = DateTime(2023, 10, 26, 10, 30);
    final tCommentModel = CommentModel(
      id: 'comment-1',
      content: '¡Qué buena publicación!',
      username: 'testuser',
      createdAt: tDateTime,
    );

    test('la instancia se puede crear con los valores correctos', () {
      expect(tCommentModel.id, 'comment-1');
      expect(tCommentModel.content, '¡Qué buena publicación!');
      expect(tCommentModel.username, 'testuser');
      expect(tCommentModel.createdAt, tDateTime);
    });

    group('fromJson', () {
      test('debe devolver un CommentModel válido desde un JSON', () {
        final Map<String, dynamic> jsonMap = {
          'id': 'comment-1',
          'content': '¡Qué buena publicación!',
          'username': 'testuser',
          'created_at': '2023-10-26T10:30:00.000Z',
        };

        final result = CommentModel.fromJson(jsonMap);

        expect(result.id, tCommentModel.id);
        expect(result.content, tCommentModel.content);
        expect(result.username, tCommentModel.username);
        expect(result.createdAt, DateTime.parse('2023-10-26T10:30:00.000Z'));
      });

      test('debe lanzar una excepción si faltan claves en el JSON', () {
        final Map<String, dynamic> invalidJson = {
          'id': '1',
        };

       expect(() => CommentModel.fromJson(invalidJson), throwsA(isA<TypeError>()));
      });
    });
  });
}
