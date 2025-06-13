import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/domain/exceptions/comments_exception.dart';

void main() {
  group('CommentsException', () {
    test('toString should return the message', () {
      const message = 'Test exception message';
      final exception = CommentsException(message);

      expect(exception.toString(), equals(message));
    });
  });
}
