import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/domain/models/comment_model.dart'; 

void main() {
  group('CommentModel', () {
    final tDateTime = DateTime(2023, 10, 26, 10, 30);
    final tCommentModelWithAllFields = CommentModel(
      id: 'comment-1',
      content: '¡Qué buena publicación!',
      username: 'testuser',
      createdAt: tDateTime,
      profileImageUrl: 'https://example.com/profile.jpg',
      attachmentUrl: 'https://example.com/attachment.png',
    );

    final tCommentModelWithoutOptionalFields = CommentModel(
      id: 'comment-2',
      content: 'Otro comentario.',
      username: 'testuser2',
      createdAt: tDateTime,
    );

    test('la instancia se puede crear con los valores correctos', () {
      expect(tCommentModelWithAllFields.id, 'comment-1');
      expect(tCommentModelWithAllFields.content, '¡Qué buena publicación!');
      expect(tCommentModelWithAllFields.username, 'testuser');
      expect(tCommentModelWithAllFields.createdAt, tDateTime);
      expect(tCommentModelWithAllFields.profileImageUrl, 'https://example.com/profile.jpg');
      expect(tCommentModelWithAllFields.attachmentUrl, 'https://example.com/attachment.png');
    });

    test('la instancia se puede crear sin campos opcionales (deben ser null)', () {
      expect(tCommentModelWithoutOptionalFields.profileImageUrl, isNull);
      expect(tCommentModelWithoutOptionalFields.attachmentUrl, isNull);
    });

    test('soporta comparación por valor (Equatable)', () {
      expect(
        tCommentModelWithAllFields,
        CommentModel(
          id: 'comment-1',
          content: '¡Qué buena publicación!',
          username: 'testuser',
          createdAt: tDateTime,
          profileImageUrl: 'https://example.com/profile.jpg',
          attachmentUrl: 'https://example.com/attachment.png',
        ),
      );
    });

    group('fromJson', () {
      test('debe devolver un CommentModel válido desde un JSON con todos los campos', () {
        final Map<String, dynamic> jsonMap = {
          'id': 'comment-1',
          'content': '¡Qué buena publicación!',
          'username': 'testuser',
          'created_at': '2023-10-26T10:30:00.000Z',
          'profile_image_url': 'https://example.com/profile.jpg',
          'attachment_url': 'https://example.com/attachment.png',
        };

        final result = CommentModel.fromJson(jsonMap);

        expect(result, equals(tCommentModelWithAllFields.copyWith(createdAt: DateTime.parse('2023-10-26T10:30:00.000Z'))));
      });
      
      test('debe devolver un CommentModel válido desde un JSON sin campos opcionales', () {
        final Map<String, dynamic> jsonMap = {
          'id': 'comment-2',
          'content': 'Otro comentario.',
          'username': 'testuser2',
          'created_at': '2023-10-26T10:30:00.000Z',
          'profile_image_url': null, 
          'attachment_url': null,
        };

        final result = CommentModel.fromJson(jsonMap);

        expect(result, equals(tCommentModelWithoutOptionalFields.copyWith(createdAt: DateTime.parse('2023-10-26T10:30:00.000Z'))));
      });

      test('debe lanzar una excepción si faltan claves requeridas en el JSON', () {
        final Map<String, dynamic> invalidJson = {'id': '1'};
        expect(() => CommentModel.fromJson(invalidJson), throwsA(isA<TypeError>()));
      });
    });
  });
}