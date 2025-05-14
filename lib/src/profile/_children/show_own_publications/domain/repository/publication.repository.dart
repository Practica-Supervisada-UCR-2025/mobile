import '../models/publication.dart';

abstract class PublicationRepository {
  Future<List<Publication>> fetchPublications({required int skip, required int limit});

}