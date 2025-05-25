import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

void main() {
  group('GifModel', () {
    test('fromJson returns correct GifModel', () {
      final json = {
        'id': 'abc123',
        'media_formats': {
          'tinygif': {'url': 'https://media.tenor.com/example.gif'}
        },
      };

      final model = GifModel.fromJson(json);

      expect(model.id, 'abc123');
      expect(model.tinyGifUrl, 'https://media.tenor.com/example.gif');
    });
  });
}
