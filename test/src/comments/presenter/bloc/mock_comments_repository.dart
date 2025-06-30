import 'package:mocktail/mocktail.dart';
import 'package:mobile/src/comments/comments.dart';

class MockCommentsRepository extends Mock implements CommentsRepository {}

class FakeDateTime extends Fake implements DateTime {}