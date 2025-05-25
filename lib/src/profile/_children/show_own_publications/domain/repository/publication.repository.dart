import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';

/// Response wrapper carrying a page of [Publication] plus metadata.
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

/// Repository interface now uses page & limit instead of skip.
abstract class PublicationRepository {
  Future<PublicationResponse> fetchPublications({
    required int page,
    required int limit,
  });
}
