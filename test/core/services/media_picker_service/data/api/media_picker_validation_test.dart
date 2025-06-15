// media_picker_validation_test.dart - Archivo separado para coverage real
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/core.dart';

void main() {
  group('MediaPickerRepositoryImpl - Real Validation Coverage', () {
    late MediaPickerRepositoryImpl repository;
    late MediaPickerConfig config;

    setUp(() {
      repository = MediaPickerRepositoryImpl();
      config = const MediaPickerConfig(
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        maxSizeInBytes: 5 * 1024 * 1024, // 5MB
        imageQuality: 80,
      );
    });

    group('validateFile', () {
      test(
        'should return valid result for allowed extension and small file',
        () async {
          final tempDir = Directory.systemTemp.createTempSync();
          final testFile = File('${tempDir.path}/test_image.jpg');
          await testFile.writeAsBytes([1, 2, 3, 4]);

          final xFile = XFile(testFile.path);

          final result = await repository.validateFile(
            file: xFile,
            config: config,
          );

          expect(result.isValid, isTrue);
          expect(result.errorMessage, isNull);

          // Cleanup
          await tempDir.delete(recursive: true);
        },
      );

      test('should return invalid result for disallowed extension', () async {
        final tempDir = Directory.systemTemp.createTempSync();
        final testFile = File('${tempDir.path}/test_image.gif');
        await testFile.writeAsBytes([1, 2, 3, 4]);

        final xFile = XFile(testFile.path);

        final result = await repository.validateFile(
          file: xFile,
          config: config,
        );

        expect(result.isValid, isFalse);
        expect(result.errorMessage, contains('File type not allowed'));
        expect(result.errorMessage, contains('jpg, jpeg, png'));

        await tempDir.delete(recursive: true);
      });

      test(
        'should return invalid result for file exceeding size limit',
        () async {
          final tempDir = Directory.systemTemp.createTempSync();
          final testFile = File('${tempDir.path}/large_image.jpg');

          final largeData = List.filled(6 * 1024 * 1024, 1); // 6MB
          await testFile.writeAsBytes(largeData);

          final xFile = XFile(testFile.path);

          final result = await repository.validateFile(
            file: xFile,
            config: config,
          );

          expect(result.isValid, isFalse);
          expect(result.errorMessage, contains('File exceeds the'));
          expect(result.errorMessage, contains('5MB limit'));

          await tempDir.delete(recursive: true);
        },
      );

      test('should handle case insensitive extensions', () async {
        final tempDir = Directory.systemTemp.createTempSync();
        final testFile = File('${tempDir.path}/test_image.JPG');
        await testFile.writeAsBytes([1, 2, 3, 4]);

        final xFile = XFile(testFile.path);

        final result = await repository.validateFile(
          file: xFile,
          config: config,
        );

        expect(result.isValid, isTrue);

        await tempDir.delete(recursive: true);
      });

      test('should handle multiple allowed extensions', () async {
        final tempDir = Directory.systemTemp.createTempSync();

        final jpegFile = File('${tempDir.path}/test.jpeg');
        await jpegFile.writeAsBytes([1, 2, 3, 4]);

        var result = await repository.validateFile(
          file: XFile(jpegFile.path),
          config: config,
        );
        expect(result.isValid, isTrue);

        final pngFile = File('${tempDir.path}/test.png');
        await pngFile.writeAsBytes([1, 2, 3, 4]);

        result = await repository.validateFile(
          file: XFile(pngFile.path),
          config: config,
        );
        expect(result.isValid, isTrue);

        await tempDir.delete(recursive: true);
      });
    });
  });
}
