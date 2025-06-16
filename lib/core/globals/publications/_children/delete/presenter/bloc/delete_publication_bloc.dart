import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/globals/publications/publications.dart';

part 'delete_publication_event.dart';
part 'delete_publication_state.dart';

class DeletePublicationBloc
    extends Bloc<DeletePublicationEvent, DeletePublicationState> {
  final DeletePublicationRepository deletePublicationRepository;

  DeletePublicationBloc({required this.deletePublicationRepository})
    : super(DeletePublicationInitial()) {
    on<DeletePublicationRequest>(_onDeletePublicationRequest);
    on<DeletePublicationReset>((event, emit) {
      emit(DeletePublicationInitial());
    });
  }

  Future<void> _onDeletePublicationRequest(
    DeletePublicationRequest event,
    Emitter<DeletePublicationState> emit,
  ) async {
    emit(DeletePublicationLoading());
    try {
      await deletePublicationRepository.deletePublication(
        publicationId: event.publicationId,
      );
      emit(DeletePublicationSuccess());
    } catch (e) {
      final cleanedError = e.toString().replaceFirst('Exception: ', '');
      emit(DeletePublicationFailure(error: cleanedError));
    }
  }
}
