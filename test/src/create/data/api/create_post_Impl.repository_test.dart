import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mobile/src/shared/models/gif_model.dart';

@GenerateMocks([ApiService, File])
import 'create_post_Impl.repository_test.mocks.dart';

void main() {
  group('CreatePostRepositoryImpl', () {
    late CreatePostRepositoryImpl repository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      repository = CreatePostRepositoryImpl(apiService: mockApiService);
    });

    group('createPost', () {
      test('toString returns the correct message', () {
        const message = 'Test error message';
        final exception = CreatePostException(message);

        expect(exception.toString(), message);
      });

      test('should create a text post successfully', () async {
        final text = 'Hello, world!';
        when(
          mockApiService.post('posts/newPost', body: {'content': text}),
        ).thenAnswer((_) async => http.Response('', 201));

        await repository.createPost(text: text);

        verify(
          mockApiService.post('posts/newPost', body: {'content': text}),
        ).called(1);
      });

      test('should throw exception when creating a text post fails', () async {
        final text = 'Hello, world!';
        when(
          mockApiService.post('posts/newPost', body: {'content': text}),
        ).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => repository.createPost(text: text),
          throwsA(isA<CreatePostException>()),
        );
        verify(
          mockApiService.post('posts/newPost', body: {'content': text}),
        ).called(1);
      });

      test('should create a post with an image successfully', () async {
        final text = 'Hello, world!';
        final imageFile = File('test/test_assets/fake_image.jpg');
        final mimeType = 'image/jpeg';
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        );
        when(
          mockApiService.postMultipart(
            'posts/newPost',
            {'content': text.isEmpty ? ' ' : text, 'mediaType': '0'},
            any,
          ),
        ).thenAnswer((_) async => http.Response('', 201));

        await repository.createPost(text: text, image: imageFile);

        verify(
          mockApiService.postMultipart(
            'posts/newPost',
            {'content': text.isEmpty ? ' ' : text, 'mediaType': '0'},
            any,
          ),
        ).called(1);
      });

      test('should throw exception when creating a post with an image fails', () async {
        final text = 'Hello, world!';
        final imageFile = File('test/test_assets/fake_image.jpg');
        final mimeType = 'image/jpeg';
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType.parse(mimeType),
        );

        when(
          mockApiService.postMultipart(
            'posts/newPost',
            {'content': text.isEmpty ? ' ' : text, 'mediaType': '0'},
            any,
          ),
        ).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => repository.createPost(text: text, image: imageFile),
          throwsA(isA<CreatePostException>()),
        );
      });

      test('should create a post with a GIF successfully', () async {
        final text = 'Hello, world!';
        final gifData = GifModel(id: '1', tinyGifUrl: 'https://example.com/gif');
        when(
          mockApiService.post(
            'posts/newPost',
            body: {'content': text, 'mediaType': 2, 'gifUrl': gifData.tinyGifUrl},
          ),
        ).thenAnswer((_) async => http.Response('', 201));

        await repository.createPost(text: text, selectedGif: gifData);

        verify(
          mockApiService.post(
            'posts/newPost',
            body: {'content': text, 'mediaType': 2, 'gifUrl': gifData.tinyGifUrl},
          ),
        ).called(1);
      });

      test('should throw exception when creating a post with a GIF fails', () async {
        final text = 'Hello, world!';
        final gifData = GifModel(id: '1', tinyGifUrl: 'https://example.com/gif');
        when(
          mockApiService.post(
            'posts/newPost',
            body: {'content': text, 'mediaType': 2, 'gifUrl': gifData.tinyGifUrl},
          ),
        ).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => repository.createPost(text: text, selectedGif: gifData),
          throwsA(isA<CreatePostException>()),
        );
        verify(
          mockApiService.post(
            'posts/newPost',
            body: {'content': text, 'mediaType': 2, 'gifUrl': gifData.tinyGifUrl},
          ),
        ).called(1);
      });

      test('should throw exception when creating an empty post', () async {
        expect(
          () => repository.createPost(),
          throwsA(isA<CreatePostException>()),
        );
      });
    });
  });
}

