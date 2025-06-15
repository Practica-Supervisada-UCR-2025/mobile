import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/models/trending_response.dart';
import 'package:mobile/src/shared/services/tenor_gif_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/core/core.dart';

@GenerateMocks([ImagePicker, PermissionsRepository, XFile, TenorGifService])
import 'media_picker_impl_test.mocks.dart';

class TestableMediaPickerRepository extends MediaPickerRepositoryImpl {
  TestableMediaPickerRepository({super.imagePicker});

  @override
  Future<ValidationResult> validateFile({
    required XFile file,
    required MediaPickerConfig config,
  }) async {
    final String extension = file.path.split('.').last.toLowerCase();

    if (!config.allowedExtensions.contains(extension)) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'File type not allowed. Use ${config.allowedExtensions.join(', ')}.',
      );
    }

    final fileName = file.path.split('/').last;
    if (fileName.contains('large')) {
      return ValidationResult(
        isValid: false,
        errorMessage:
            'File exceeds the ${config.maxSizeInBytes ~/ (1024 * 1024)}MB limit.',
      );
    }

    return ValidationResult(isValid: true);
  }
}

void main() {
  group('MediaPickerRepositoryImpl', () {
    late TestableMediaPickerRepository repository;
    late MockImagePicker mockImagePicker;
    late MockPermissionsRepository mockPermissionsRepository;
    late MockXFile mockXFile;
    late MediaPickerConfig config;
    late MockTenorGifService mockTenorGifService;

    setUp(() {
      mockImagePicker = MockImagePicker();
      mockPermissionsRepository = MockPermissionsRepository();
      mockXFile = MockXFile();
      mockTenorGifService = MockTenorGifService();
      repository = TestableMediaPickerRepository(imagePicker: mockImagePicker);

      config = const MediaPickerConfig(
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        maxSizeInBytes: 5 * 1024 * 1024, // 5MB
        imageQuality: 80,
      );
    });

    group('pickImageFromGallery', () {
      testWidgets(
        'should return File when permission granted and valid image selected',
        (WidgetTester tester) async {
          const testImagePath = '/test/image.jpg';

          when(
            mockPermissionsRepository.checkGalleryPermission(
              context: anyNamed('context'),
            ),
          ).thenAnswer((_) async => true);

          when(
            mockImagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: config.imageQuality,
            ),
          ).thenAnswer((_) async => mockXFile);

          when(mockXFile.path).thenReturn(testImagePath);

          late BuildContext testContext;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RepositoryProvider<PermissionsRepository>(
                  create: (context) => mockPermissionsRepository,
                  child: Builder(
                    builder: (context) {
                      testContext = context;
                      return Container();
                    },
                  ),
                ),
              ),
            ),
          );

          File? result = await repository.pickImageFromGallery(
            context: testContext,
            config: config,
          );

          expect(result, isNotNull);
          expect(result!.path, equals(testImagePath));
        },
      );

      testWidgets('should return null when permission denied', (
        WidgetTester tester,
      ) async {
        when(
          mockPermissionsRepository.checkGalleryPermission(
            context: anyNamed('context'),
          ),
        ).thenAnswer((_) async => false);

        late BuildContext testContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RepositoryProvider<PermissionsRepository>(
                create: (context) => mockPermissionsRepository,
                child: Builder(
                  builder: (context) {
                    testContext = context;
                    return Container();
                  },
                ),
              ),
            ),
          ),
        );

        File? result = await repository.pickImageFromGallery(
          context: testContext,
          config: config,
        );

        expect(result, isNull);
        verifyNever(
          mockImagePicker.pickImage(
            source: anyNamed('source'),
            imageQuality: anyNamed('imageQuality'),
          ),
        );
      });

      testWidgets(
        'should return File when permission granted and valid image selected',
        (WidgetTester tester) async {
          const testImagePath = '/test/image.jpg';

          when(
            mockPermissionsRepository.checkGalleryPermission(
              context: anyNamed('context'),
            ),
          ).thenAnswer((_) async {
            return true;
          });

          when(
            mockImagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: config.imageQuality,
            ),
          ).thenAnswer((_) async {
            return mockXFile;
          });

          when(mockXFile.path).thenReturn(testImagePath);

          late BuildContext testContext;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RepositoryProvider<PermissionsRepository>(
                  create: (context) => mockPermissionsRepository,
                  child: Builder(
                    builder: (context) {
                      testContext = context;
                      return Container();
                    },
                  ),
                ),
              ),
            ),
          );

          File? result = await repository.pickImageFromGallery(
            context: testContext,
            config: config,
          );

          expect(result, isNotNull);
          expect(result!.path, equals(testImagePath));
        },
      );

      testWidgets('should return null when no image selected', (
        WidgetTester tester,
      ) async {
        when(
          mockPermissionsRepository.checkGalleryPermission(
            context: anyNamed('context'),
          ),
        ).thenAnswer((_) async => true);

        when(
          mockImagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: config.imageQuality,
          ),
        ).thenAnswer((_) async => null);

        late BuildContext testContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RepositoryProvider<PermissionsRepository>(
                create: (context) => mockPermissionsRepository,
                child: Builder(
                  builder: (context) {
                    testContext = context;
                    return Container();
                  },
                ),
              ),
            ),
          ),
        );

        File? result = await repository.pickImageFromGallery(
          context: testContext,
          config: config,
        );

        expect(result, isNull);
      });

      testWidgets(
        'should return null and call onInvalidFile when file validation fails',
        (WidgetTester tester) async {
          const testImagePath = '/test/image.bmp'; // Invalid extension
          String? errorMessage;

          final configWithCallback = MediaPickerConfig(
            allowedExtensions: const ['jpg', 'jpeg', 'png'],
            maxSizeInBytes: 5 * 1024 * 1024,
            imageQuality: 80,
            onInvalidFile: (message) {
              errorMessage = message;
            },
          );

          when(
            mockPermissionsRepository.checkGalleryPermission(
              context: anyNamed('context'),
            ),
          ).thenAnswer((_) async => true);

          when(
            mockImagePicker.pickImage(
              source: ImageSource.gallery,
              imageQuality: configWithCallback.imageQuality,
            ),
          ).thenAnswer((_) async => mockXFile);

          when(mockXFile.path).thenReturn(testImagePath);

          late BuildContext testContext;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RepositoryProvider<PermissionsRepository>(
                  create: (context) => mockPermissionsRepository,
                  child: Builder(
                    builder: (context) {
                      testContext = context;
                      return Container();
                    },
                  ),
                ),
              ),
            ),
          );

          File? result = await repository.pickImageFromGallery(
            context: testContext,
            config: configWithCallback,
          );

          expect(result, isNull);
          expect(errorMessage, isNotNull);
          expect(errorMessage, contains('File type not allowed'));
        },
      );
    });

    group('takePhoto', () {
      testWidgets(
        'should return File when permission granted and valid photo taken',
        (WidgetTester tester) async {
          const testImagePath = '/test/photo.jpg';

          when(
            mockPermissionsRepository.checkCameraPermission(
              context: anyNamed('context'),
            ),
          ).thenAnswer((_) async => true);

          when(
            mockImagePicker.pickImage(
              source: ImageSource.camera,
              imageQuality: config.imageQuality,
            ),
          ).thenAnswer((_) async => mockXFile);

          when(mockXFile.path).thenReturn(testImagePath);

          late BuildContext testContext;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RepositoryProvider<PermissionsRepository>(
                  create: (context) => mockPermissionsRepository,
                  child: Builder(
                    builder: (context) {
                      testContext = context;
                      return Container();
                    },
                  ),
                ),
              ),
            ),
          );

          File? result = await repository.takePhoto(
            context: testContext,
            config: config,
          );

          expect(result, isNotNull);
          expect(result!.path, equals(testImagePath));
        },
      );

      testWidgets('should return null when camera permission denied', (
        WidgetTester tester,
      ) async {
        when(
          mockPermissionsRepository.checkCameraPermission(
            context: anyNamed('context'),
          ),
        ).thenAnswer((_) async => false);

        late BuildContext testContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RepositoryProvider<PermissionsRepository>(
                create: (context) => mockPermissionsRepository,
                child: Builder(
                  builder: (context) {
                    testContext = context;
                    return Container();
                  },
                ),
              ),
            ),
          ),
        );

        File? result = await repository.takePhoto(
          context: testContext,
          config: config,
        );

        expect(result, isNull);
        verifyNever(
          mockImagePicker.pickImage(
            source: anyNamed('source'),
            imageQuality: anyNamed('imageQuality'),
          ),
        );
      });

      testWidgets('should return null when no photo taken', (
        WidgetTester tester,
      ) async {
        when(
          mockPermissionsRepository.checkCameraPermission(
            context: anyNamed('context'),
          ),
        ).thenAnswer((_) async => true);

        when(
          mockImagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: config.imageQuality,
          ),
        ).thenAnswer((_) async => null);

        late BuildContext testContext;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RepositoryProvider<PermissionsRepository>(
                create: (context) => mockPermissionsRepository,
                child: Builder(
                  builder: (context) {
                    testContext = context;
                    return Container();
                  },
                ),
              ),
            ),
          ),
        );

        File? result = await repository.takePhoto(
          context: testContext,
          config: config,
        );

        expect(result, isNull);
      });

      testWidgets(
        'should return null and call onInvalidFile when photo validation fails',
        (WidgetTester tester) async {
          const testImagePath =
              '/test/large_photo.jpg'; // Will trigger size validation failure
          String? errorMessage;

          final configWithCallback = MediaPickerConfig(
            allowedExtensions: const ['jpg', 'jpeg', 'png'],
            maxSizeInBytes: 5 * 1024 * 1024,
            imageQuality: 80,
            onInvalidFile: (message) {
              errorMessage = message;
            },
          );

          when(
            mockPermissionsRepository.checkCameraPermission(
              context: anyNamed('context'),
            ),
          ).thenAnswer((_) async => true);

          when(
            mockImagePicker.pickImage(
              source: ImageSource.camera,
              imageQuality: configWithCallback.imageQuality,
            ),
          ).thenAnswer((_) async => mockXFile);

          when(mockXFile.path).thenReturn(testImagePath);

          late BuildContext testContext;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: RepositoryProvider<PermissionsRepository>(
                  create: (context) => mockPermissionsRepository,
                  child: Builder(
                    builder: (context) {
                      testContext = context;
                      return Container();
                    },
                  ),
                ),
              ),
            ),
          );

          File? result = await repository.takePhoto(
            context: testContext,
            config: configWithCallback,
          );

          expect(result, isNull);
          expect(errorMessage, isNotNull);
          expect(errorMessage, contains('File exceeds the'));
        },
      );
    });

    group('pickGifFromTenor', () {
      testWidgets(
        'should show bottom sheet and return null when no gif selected',
        (WidgetTester tester) async {
          when(
            mockTenorGifService.getTrendingGifs(
              limit: anyNamed('limit'),
              pos: anyNamed('pos'),
            ),
          ).thenAnswer((_) async => TrendingGifResponse(gifs: []));

          GifModel? pickedGif;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        pickedGif = await repository.pickGifFromTenor(
                          context: context,
                          gifService: mockTenorGifService,
                        );
                      },
                      child: const Text('Pick GIF'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Pick GIF'));
          await tester.pumpAndSettle();

          expect(find.byType(BottomSheet), findsOneWidget);

          await tester.tapAt(const Offset(50, 50));
          await tester.pumpAndSettle();

          expect(pickedGif, isNull);
        },
      );

      testWidgets(
        'should return selected gif when one is picked from bottom sheet',
        (WidgetTester tester) async {
          final fakeGif = GifModel(
            id: '123',
            tinyGifUrl: 'http://example.com/gif.gif',
          );

          when(
            mockTenorGifService.getTrendingGifs(
              limit: anyNamed('limit'),
              pos: anyNamed('pos'),
            ),
          ).thenAnswer((_) async => TrendingGifResponse(gifs: [fakeGif]));

          GifModel? pickedGif;

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (context) {
                    return ElevatedButton(
                      onPressed: () async {
                        pickedGif = await repository.pickGifFromTenor(
                          context: context,
                          gifService: mockTenorGifService,
                        );
                      },
                      child: const Text('Pick GIF'),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.tap(find.text('Pick GIF'));
          await tester.pumpAndSettle();

          await tester.tap(find.byKey(const Key('gif_123')));
          await tester.pumpAndSettle();

          expect(pickedGif, isNotNull);
          expect(pickedGif!.id, equals('123'));
          expect(pickedGif?.tinyGifUrl, equals('http://example.com/gif.gif'));
        },
      );
    });
    group('MediaPickerConfig Tests', () {
      test('copyWith should return new instance with updated values', () {
        final original = MediaPickerConfig(
          allowedExtensions: ['jpg', 'png'],
          maxSizeInBytes: 1024,
          imageQuality: 90,
          onInvalidFile: (message) {},
        );

        // Act
        final copied = original.copyWith(
          allowedExtensions: ['gif', 'webp'],
          maxSizeInBytes: 2048,
        );

        // Assert
        expect(copied.allowedExtensions, equals(['gif', 'webp']));
        expect(copied.maxSizeInBytes, equals(2048));
        expect(copied.imageQuality, equals(90));
        expect(copied.onInvalidFile, equals(original.onInvalidFile));
      });

      test(
        'copyWith should keep original values when no parameters provided',
        () {
          void testCallback(String message) {}
          final original = MediaPickerConfig(
            allowedExtensions: ['mp4', 'avi'],
            maxSizeInBytes: 5000,
            imageQuality: 75,
            onInvalidFile: testCallback,
          );
          final copied = original.copyWith();

          expect(copied.allowedExtensions, equals(['mp4', 'avi']));
          expect(copied.maxSizeInBytes, equals(5000));
          expect(copied.imageQuality, equals(75));
          expect(copied.onInvalidFile, equals(testCallback));
        },
      );
    });
  });
}
