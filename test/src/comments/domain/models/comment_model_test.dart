import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/domain/models/comment_model.dart';

void main() {
  group('CommentModel', () {
    final tDateTime = DateTime(2023, 10, 26, 10, 30);
    final tCommentModelWithAllFields = CommentModel(
      id: 'comment-1',
      content: 'What a great post!',
      username: 'testuser',
      userId: '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
      createdAt: tDateTime,
      profileImageUrl: 'https://example.com/profile.jpg',
      attachmentUrl: 'https://example.com/attachment.png',
    );

    final tCommentModelWithoutOptionalFields = CommentModel(
      id: 'comment-2',
      content: 'Another comment.',
      username: 'testuser2',
      userId: '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
      createdAt: tDateTime,
    );

    test('instance can be created with correct values', () {
      expect(tCommentModelWithAllFields.id, 'comment-1');
      expect(tCommentModelWithAllFields.content, 'What a great post!');
      expect(tCommentModelWithAllFields.username, 'testuser');
      expect(tCommentModelWithAllFields.createdAt, tDateTime);
      expect(tCommentModelWithAllFields.profileImageUrl, 'https://example.com/profile.jpg');
      expect(tCommentModelWithAllFields.attachmentUrl, 'https://example.com/attachment.png');
    });

    test('instance can be created without optional fields (they should be null)', () {
      expect(tCommentModelWithoutOptionalFields.profileImageUrl, isNull);
      expect(tCommentModelWithoutOptionalFields.attachmentUrl, isNull);
    });

    test('supports value comparison (Equatable)', () {
      expect(
        tCommentModelWithAllFields,
        CommentModel(
          id: 'comment-1',
          content: 'What a great post!',
          username: 'testuser',
          userId: '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
          createdAt: tDateTime,
          profileImageUrl: 'https://example.com/profile.jpg',
          attachmentUrl: 'https://example.com/attachment.png',
        ),
      );
    });

    group('fromJson', () {
      test('should return a valid CommentModel from JSON with all fields', () {
        final Map<String, dynamic> jsonMap = {
          'id': 'comment-1',
          'content': 'What a great post!',
          'username': 'testuser',
          'user_id': '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
          'created_at': '2023-10-26T10:30:00.000Z',
          'profile_picture': 'https://example.com/profile.jpg',
          'file_url': 'https://example.com/attachment.png',
        };

        final result = CommentModel.fromJson(jsonMap);

        expect(result, equals(tCommentModelWithAllFields.copyWith(createdAt: DateTime.parse('2023-10-26T10:30:00.000Z'))));
      });

      test('should return a valid CommentModel from JSON without optional fields', () {
        final Map<String, dynamic> jsonMap = {
          'id': 'comment-2',
          'content': 'Another comment.',
          'username': 'testuser2',
          'user_id': '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
          'created_at': '2023-10-26T10:30:00.000Z',
          'profile_picture': null,
          'file_url': null,
        };

        final result = CommentModel.fromJson(jsonMap);

        expect(result, equals(tCommentModelWithoutOptionalFields.copyWith(createdAt: DateTime.parse('2023-10-26T10:30:00.000Z'))));
      });

      test('should throw an exception if required keys are missing from JSON', () {
        final Map<String, dynamic> invalidJson = {'id': '1'};
        expect(() => CommentModel.fromJson(invalidJson), throwsA(isA<TypeError>()));
      });
    });
  });
}