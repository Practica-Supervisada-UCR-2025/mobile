import '../models/publication.dart';

abstract class PublicationRepository {
  Future<List<Publication>> fetchPublications({int limit = 14});
}
