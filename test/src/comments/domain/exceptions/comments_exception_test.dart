import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/domain/exceptions/comments_exception.dart';

void main() {
  group('CommentsException', () {
    test('toString() debe devolver el mensaje correcto', () {
      const errorMessage = 'Ocurrió un error inesperado al cargar los comentarios.';
      final exception = CommentsException(errorMessage);

      final result = exception.toString();

      expect(result, equals(errorMessage));
    });

    test('dos instancias con el mismo mensaje tienen el mismo mensaje', () {
      const errorMessage = 'Error';
      final exception1 = CommentsException(errorMessage);
      final exception2 = CommentsException(errorMessage);
        expect(exception1.message, equals(exception2.message));
    });

    test('toString should return the message', () {
      const message = 'Test exception message';
      final exception = CommentsException(message);

      expect(exception.toString(), equals(message));
    });
  });
}