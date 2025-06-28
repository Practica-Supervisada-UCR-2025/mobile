import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/comments.dart';

void main() {
  final tCommentModel1 = CommentModel(
    id: '1',
    content: 'Comentario 1',
    username: 'user1',
    userId: '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
    createdAt: DateTime.utc(2023, 1, 1, 12),
    profileImageUrl: 'https://example.com/user1.jpg',
    attachmentUrl: null,
  );

  final tCommentsResponse = CommentsResponse(
    comments: [tCommentModel1],
    totalItems: 5,
    currentIndex: 0,
  );
  
  group('fromJson', () {
    test('debe devolver un CommentsResponse válido desde un JSON completo', () {
      final Map<String, dynamic> jsonMap = {
        'comments': [
          {
            'id': '1',
            'content': 'Comentario 1',
            'username': 'user1',
            'user_id': '9130bc4e-bf89-455f-a7cc-3a2f0a65bb79',
            'created_at': '2023-01-01T12:00:00.000Z',
            'profile_picture': 'https://example.com/user1.jpg',
            'file_url': null,
          }
        ],
        'metadata': {'totalItems': 5, 'currentIndex': 0}
      };

      final result = CommentsResponse.fromJson(jsonMap);
      
      expect(result, tCommentsResponse);
    });
  });
}