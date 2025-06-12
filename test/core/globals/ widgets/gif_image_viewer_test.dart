import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/globals/widgets/gif_viewer.dart';
import 'package:mocktail/mocktail.dart';

class MockFile extends Mock implements File {
  final String mockPath;
  final Completer<Uint8List> _completer = Completer<Uint8List>();
  
  MockFile(this.mockPath);
  
  @override
  String get path => mockPath;
  
  @override
  Future<int> length() async => 1024;
  
  @override
  Future<Uint8List> readAsBytes() {
    return _completer.future;
  }
  
  void completeLoading() {
    if (!_completer.isCompleted) {
      _completer.complete(Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
        0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
        0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
        0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
        0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
        0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
      ]));
    }
  }
}

void main() {
  Widget createWidgetUnderTest(File gifFile) {
    return MaterialApp(
      home: Scaffold(
        body: GifImageViewer(
          imageFile: gifFile,
        ),
      ),
    );
  }
  
  group('GifImageViewer', () {
    testWidgets('should reinitialize when imageFile changes', 
        (WidgetTester tester) async {
      final firstGif = MockFile('test_gif_1.gif');
      final secondGif = MockFile('test_gif_2.gif');
      
      await tester.pumpWidget(createWidgetUnderTest(firstGif));
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      firstGif.completeLoading();
      await tester.pumpAndSettle();
      
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      
      await tester.pumpWidget(createWidgetUnderTest(secondGif));
      await tester.pump();
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      secondGif.completeLoading();
      await tester.pumpAndSettle();
      
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}