part of 'report_publication_bloc.dart';

abstract class ReportPublicationEvent extends Equatable {
  const ReportPublicationEvent();

  @override
  List<Object> get props => [];
}

class ReportPublicationRequest extends ReportPublicationEvent {
  final String publicationId;
  final String reason;

  const ReportPublicationRequest({
    required this.publicationId,
    required this.reason,
  });

  @override
  List<Object> get props => [publicationId, reason];
}
