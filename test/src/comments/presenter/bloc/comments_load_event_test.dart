import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/src/comments/presenter/bloc_load/comments_load_bloc.dart';

void main() {
  group('CommentsLoadEvent', () {
    test('props de FetchInitialComments están vacíos', () {
      expect(FetchInitialComments().props, []);
    });

    test('props de FetchMoreComments están vacíos', () {
      expect(FetchMoreComments().props, []);
    });

    test('comparación de igualdad funciona', () {
      expect(FetchInitialComments(), FetchInitialComments());
      expect(FetchMoreComments(), FetchMoreComments());
    });
  });
}
