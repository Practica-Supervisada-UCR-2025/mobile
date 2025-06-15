import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/core/core.dart';
import 'package:mobile/src/comments/comments.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'comments_Impl.repository_test.mocks.dart';

@GenerateMocks([ApiService, File])
void main() {
  group('CommentsRepositoryImpl', () {
    late CommentsRepositoryImpl repository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      repository = CommentsRepositoryImpl(apiService: mockApiService);
    });

    group('sendComment', () {
      test('should send a text comment successfully', () async {
        final postId = 'post123';
        final text = 'Hello, world!';
        when(
          mockApiService.post('posts/newComment', body: {'content': text, 'postId': postId}),
        ).thenAnswer((_) async => http.Response('', 201));

        await repository.sendComment(postId: postId, text: text);

        verify(
          mockApiService.post('posts/newComment', body: {'content': text, 'postId': postId}),
        ).called(1);
      });

      test('should throw exception when sending a text comment fails', () async {
        final postId = 'post123';
        final text = 'Hello, world!';
        when(
          mockApiService.post('posts/newComment', body: {'content': text, 'postId': postId}),
        ).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => repository.sendComment(postId: postId, text: text),
          throwsA(isA<CommentsException>()),
        );
        verify(
          mockApiService.post('posts/newComment', body: {'content': text, 'postId': postId}),
        ).called(1);
      });

      test('should send a comment with an image successfully', () async {
        final postId = 'post123';
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
            'posts/newComment',
            {'content': text.isEmpty ? ' ' : text, 'mediaType': '0', 'postId': postId},
            any,
          ),
        ).thenAnswer((_) async => http.Response('', 201));

        await repository.sendComment(postId: postId, text: text, image: imageFile);

        verify(
          mockApiService.postMultipart(
            'posts/newComment',
            {'content': text.isEmpty ? ' ' : text, 'mediaType': '0', 'postId': postId},
            any,
          ),
        ).called(1);
      });

      test('should throw exception when sending a comment with an image fails', () async {
        final postId = 'post123';
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
            'posts/newComment',
            {'content': text.isEmpty ? ' ' : text, 'mediaType': '0', 'postId': postId},
            any,
          ),
        ).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => repository.sendComment(postId: postId, text: text, image: imageFile),
          throwsA(isA<CommentsException>()),
        );
      });

      test('should send a comment with a GIF successfully', () async {
        final postId = 'post123';
        final text = 'Hello, world!';
        final gifData = GifModel(id: '1', tinyGifUrl: 'https://example.com/gif');
        when(
          mockApiService.post(
            'posts/newComment',
            body: {'content': text.isEmpty ? ' ' : text, 'mediaType': 2, 'gifUrl': gifData.tinyGifUrl, 'postId': postId},
          ),
        ).thenAnswer((_) async => http.Response('', 201));

        await repository.sendComment(postId: postId, text: text, selectedGif: gifData);

        verify(
          mockApiService.post(
            'posts/newComment',
            body: {'content': text.isEmpty ? ' ' : text, 'mediaType': 2, 'gifUrl': gifData.tinyGifUrl, 'postId': postId},
          ),
        ).called(1);
      });

      test('should throw exception when sending a comment with a GIF fails', () async {
        final postId = 'post123';
        final text = 'Hello, world!';
        final gifData = GifModel(id: '1', tinyGifUrl: 'https://example.com/gif');
        when(
          mockApiService.post(
            'posts/newComment',
            body: {'content': text.isEmpty ? ' ' : text, 'mediaType': 2, 'gifUrl': gifData.tinyGifUrl, 'postId': postId},
          ),
        ).thenAnswer((_) async => http.Response('Error', 400));

        expect(
          () => repository.sendComment(postId: postId, text: text, selectedGif: gifData),
          throwsA(isA<CommentsException>()),
        );
        verify(
          mockApiService.post(
            'posts/newComment',
            body: {'content': text.isEmpty ? ' ' : text, 'mediaType': 2, 'gifUrl': gifData.tinyGifUrl, 'postId': postId},
          ),
        ).called(1);
      });

      test('should throw exception when sending an empty comment', () async {
        final postId = 'post123';
        expect(
          () => repository.sendComment(postId: postId),
          throwsA(isA<CommentsException>()),
        );
      });

      test('should throw CommentsException when failed to send comment', () async {
        final postId = 'post123';
        final text = 'Hello, world!';
        when(
          mockApiService.post(
            'posts/newComment',
            body: {'content': text, 'postId': postId},
          ),
        ).thenAnswer((_) async => http.Response('{"message": "Server error"}', 400));

        expect(
          () => repository.sendComment(postId: postId, text: text),
          throwsA(
            isA<CommentsException>().having(
              (e) => e.message,
              'message',
              'Failed to send comment: Server error',
            ),
          ),
        );
      });
    });
  });
}



