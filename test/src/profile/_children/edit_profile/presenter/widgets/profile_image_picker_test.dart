import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:mobile/core/core.dart';
import 'package:network_image_mock/network_image_mock.dart';

// Generate mocks
@GenerateMocks([MediaPickerRepository])
import 'profile_image_picker_test.mocks.dart';

void main() {
  late MockMediaPickerRepository mockMediaPickerRepository;
  late File? selectedImage;
  late Function(File?) onImageSelected;

  setUp(() {
    mockMediaPickerRepository = MockMediaPickerRepository();
    selectedImage = null;
    onImageSelected = (File? image) {
      selectedImage = image;
    };
  });

  Widget createWidgetUnderTest({
    String currentImage = 'https://example.com/profile.jpg',
    File? selectedImg,
  }) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder:
              (context, state) => Scaffold(
                body: ProfileImagePicker(
                  currentImage: currentImage,
                  selectedImage: selectedImg ?? selectedImage,
                  onImageSelected: onImageSelected,
                ),
              ),
        ),
      ],
    );

    return RepositoryProvider<MediaPickerRepository>.value(
      value: mockMediaPickerRepository,
      child: MaterialApp.router(routerConfig: router),
    );
  }

  group('ProfileImagePicker', () {
    testWidgets('renders correctly with network image', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);

        final circleAvatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar),
        );
        expect(circleAvatar.backgroundImage, isA<NetworkImage>());
      });
    });

    testWidgets(
      'renders with default profile picture when no image is provided',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createWidgetUnderTest(currentImage: ''));

          expect(find.byType(CircleAvatar), findsOneWidget);
          expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);

          final circleAvatar = tester.widget<CircleAvatar>(
            find.byType(CircleAvatar),
          );
          expect(circleAvatar.backgroundImage, isA<NetworkImage>());
          final networkImage = circleAvatar.backgroundImage as NetworkImage;
          expect(networkImage.url, equals(DEFAULT_PROFILE_PIC_2));
        });
      },
    );

    testWidgets('renders with selected file image when provided', (
      tester,
    ) async {
      final mockFile = File('test_image.jpg');

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(selectedImg: mockFile));

        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);

        final circleAvatar = tester.widget<CircleAvatar>(
          find.byType(CircleAvatar),
        );
        expect(circleAvatar.backgroundImage, isA<FileImage>());
      });
    });

    testWidgets('shows image source options when tapped', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        expect(find.text('Select Image Source'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Delete Image'), findsOneWidget);
      });
    });

    testWidgets('hides delete option when no image is available', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest(currentImage: ''));

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        expect(find.text('Select Image Source'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Delete Image'), findsNothing);
      });
    });

    testWidgets('calls onImageSelected with null when delete is tapped', (
      tester,
    ) async {
      File? capturedImage;
      testOnImageSelected(File? image) {
        capturedImage = image;
      }

      await mockNetworkImagesFor(() async {
        final router = GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(
              path: '/',
              builder:
                  (context, state) => Scaffold(
                    body: RepositoryProvider<MediaPickerRepository>.value(
                      value: mockMediaPickerRepository,
                      child: Builder(
                        builder: (context) {
                          return ProfileImagePicker(
                            currentImage: 'https://example.com/profile.jpg',
                            selectedImage: null,
                            onImageSelected: testOnImageSelected,
                          );
                        },
                      ),
                    ),
                  ),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(routerConfig: router));

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete Image'));
        await tester.pumpAndSettle();

        expect(capturedImage, isNull);
      });
    });

    testWidgets(
      'calls MediaPickerRepository.pickImageFromGallery when gallery is tapped',
      (tester) async {
        final mockFile = File('gallery_image.jpg');
        when(
          mockMediaPickerRepository.pickImageFromGallery(
            context: anyNamed('context'),
            config: anyNamed('config'),
          ),
        ).thenAnswer((_) async => mockFile);

        await mockNetworkImagesFor(() async {
          await tester.pumpWidget(createWidgetUnderTest());

          await tester.tap(find.byType(GestureDetector));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Gallery'));
          await tester.pumpAndSettle();

          verify(
            mockMediaPickerRepository.pickImageFromGallery(
              context: anyNamed('context'),
              config: anyNamed('config'),
            ),
          ).called(1);
        });
      },
    );

    testWidgets('calls MediaPickerRepository.takePhoto when camera is tapped', (
      tester,
    ) async {
      final mockFile = File('camera_photo.jpg');
      when(
        mockMediaPickerRepository.takePhoto(
          context: anyNamed('context'),
          config: anyNamed('config'),
        ),
      ).thenAnswer((_) async => mockFile);

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Camera'));
        await tester.pumpAndSettle();

        verify(
          mockMediaPickerRepository.takePhoto(
            context: anyNamed('context'),
            config: anyNamed('config'),
          ),
        ).called(1);
      });
    });

    testWidgets('shows snackbar when gallery selection fails with error', (
      tester,
    ) async {
      const errorMessage = 'File too large';
      when(
        mockMediaPickerRepository.pickImageFromGallery(
          context: anyNamed('context'),
          config: anyNamed('config'),
        ),
      ).thenAnswer((invocation) async {
        final config = invocation.namedArguments[#config] as MediaPickerConfig;
        config.onInvalidFile?.call(errorMessage);
        return null;
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Gallery'));
        await tester.pumpAndSettle();

        expect(find.text(errorMessage), findsOneWidget);
      });
    });

    testWidgets('shows snackbar when camera capture fails with error', (
      tester,
    ) async {
      const errorMessage = 'Invalid file format';
      when(
        mockMediaPickerRepository.takePhoto(
          context: anyNamed('context'),
          config: anyNamed('config'),
        ),
      ).thenAnswer((invocation) async {
        final config = invocation.namedArguments[#config] as MediaPickerConfig;
        config.onInvalidFile?.call(errorMessage);
        return null;
      });

      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Camera'));
        await tester.pumpAndSettle();

        expect(find.text(errorMessage), findsOneWidget);
      });
    });
  });
}
