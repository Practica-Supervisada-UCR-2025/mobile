abstract class ReportPublicationRepository {
  Future<void> reportPublication({
    required String publicationId,
    required String reason,
  });
}
