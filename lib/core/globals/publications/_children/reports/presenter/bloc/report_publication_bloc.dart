import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/globals/publications/publications.dart';

part 'report_publication_event.dart';
part 'report_publication_state.dart';

class ReportPublicationBloc
    extends Bloc<ReportPublicationEvent, ReportPublicationState> {
  final ReportPublicationRepository reportPublicationRepository;

  ReportPublicationBloc({required this.reportPublicationRepository})
    : super(ReportPublicationInitial()) {
    on<ReportPublicationRequest>(_onReportPublicationRequest);
    on<ReportPublicationReset>((event, emit) {
      emit(ReportPublicationInitial());
    });
  }

  Future<void> _onReportPublicationRequest(
    ReportPublicationRequest event,
    Emitter<ReportPublicationState> emit,
  ) async {
    emit(ReportPublicationLoading());
    try {
      await reportPublicationRepository.reportPublication(
        publicationId: event.publicationId,
        reason: event.reason,
      );
      emit(ReportPublicationSuccess());
    } catch (e) {
      final cleanedError = e.toString().replaceFirst('Exception: ', '');
      emit(ReportPublicationFailure(error: cleanedError));
    }
  }
}
