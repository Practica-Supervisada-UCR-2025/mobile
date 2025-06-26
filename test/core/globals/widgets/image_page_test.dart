import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/globals/publications/presenter/widgets/image_page.dart';
import 'package:mobile/core/globals/widgets/feedback_snack_bar.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:flutter/material.dart';

void main() {
  const imageUrl = 'https://example.com/image.jpg';

  testWidgets('ImagePreviewScreen displays image and handles download',
      (WidgetTester tester) async {
    bool downloadCalled = false;

    mockDownload({
      required String url,
      Function(String)? onDownloadCompleted,
      Function(String)? onDownloadError,
    }) {
      downloadCalled = true;
      onDownloadCompleted?.call('/fake/path/image.jpg');
    }

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: ImagePreviewScreen(
            imageUrl: imageUrl,
            downloadFn: mockDownload,
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);

      await tester.tap(find.byIcon(Icons.download));
      await tester.pump();

      expect(downloadCalled, isTrue);

      await tester.pumpAndSettle();
      expect(find.text('Image downloaded successfully'), findsOneWidget);
    });
  });
}
