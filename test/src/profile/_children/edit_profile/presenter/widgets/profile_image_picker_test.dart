import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile/src/profile/profile.dart';
import 'package:mobile/core/core.dart';
import 'package:network_image_mock/network_image_mock.dart';

// Mocks
class MockPermissionsRepository extends Mock implements PermissionsRepository {}

void main() {
  late MockPermissionsRepository mockPermissionsRepository;
  late File? selectedImage;
  late Function(File?) onImageSelected;

  setUp(() {
    mockPermissionsRepository = MockPermissionsRepository();
    selectedImage = null;
    onImageSelected = (File? image) {
      selectedImage = image;
    };
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: RepositoryProvider<PermissionsRepository>.value(
          value: mockPermissionsRepository,
          child: Builder(
            builder: (context) {
              return ProfileImagePicker(
                currentImage: 'https://example.com/profile.jpg',
                selectedImage: selectedImage,
                onImageSelected: onImageSelected,
              );
            },
          ),
        ),
      ),
    );
  }

  group('ProfileImagePicker', () {
    testWidgets('renders correctly with network image', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(CircleAvatar), findsOneWidget);
        expect(find.byIcon(Icons.add_a_photo_rounded), findsOneWidget);
        expect(find.byIcon(Icons.person), findsNothing);
      });
    });

    testWidgets('renders person icon when no image is provided', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RepositoryProvider<PermissionsRepository>.value(
                value: mockPermissionsRepository,
                child: Builder(
                  builder: (context) {
                    return ProfileImagePicker(
                      currentImage: '',
                      selectedImage: null,
                      onImageSelected: onImageSelected,
                    );
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.byIcon(Icons.person), findsOneWidget);
      });
    });

    testWidgets('shows image source options when tapped', (tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        expect(find.text('Select Image Source'), findsOneWidget);
        expect(find.text('Gallery'), findsOneWidget);
        expect(find.text('Camera'), findsOneWidget);
        expect(find.text('Delete Image'), findsOneWidget);
      });
    });
  });
}
