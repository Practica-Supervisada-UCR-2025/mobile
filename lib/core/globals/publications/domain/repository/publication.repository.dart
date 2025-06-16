import 'package:mobile/core/globals/publications/publications.dart';

class PublicationResponse {
  final List<Publication> publications;
  final int totalPosts;
  final int totalPages;
  final int currentPage;

  PublicationResponse({
    required this.publications,
    required this.totalPosts,
    required this.totalPages,
    required this.currentPage,
  });
}

abstract class PublicationRepository {
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
    String? time,
  });
}
