import '../models/publication.dart';

abstract class PublicationRepository {
  Future<List<Publication>> fetchPublications({int limit = 14});

  //Future<List<Publication>> fetchPublications(int page, int limit);
}
