import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/src/profile/profile.dart';

part 'publication_event.dart';
part 'publication_state.dart';

class PublicationBloc extends Bloc<PublicationEvent, PublicationState> {
  final PublicationRepository publicationRepository;

  PublicationBloc({required this.publicationRepository}) : super(PublicationInitial()) {
    on<LoadPublications>(_onLoadPublications);
    on<LoadMorePublications>(_onLoadMorePublications);
  }

  Future<void> _onLoadPublications(
    LoadPublications event,
    Emitter<PublicationState> emit,
  ) async {
    emit(PublicationLoading());

    try {
      //final publications = await publicationRepository.fetchPublications(page, limit);
      final publications = await publicationRepository.fetchPublications(limit: 14);
      emit(PublicationSuccess(publications: publications, hasReachedMax: publications.length < 14));
    } catch (_) {
      emit(PublicationFailure());
    }
  }

  Future<void> _onLoadMorePublications(
    LoadMorePublications event,
    Emitter<PublicationState> emit,
  ) async {
    if (state is! PublicationSuccess) return;

    final currentState = state as PublicationSuccess;

    if (currentState.hasReachedMax) return;

    try {
      final morePublications = await publicationRepository.fetchPublications(limit: 14);

      final allPublications = List.of(currentState.publications)..addAll(morePublications);

      emit(PublicationSuccess(
        publications: allPublications,
        hasReachedMax: morePublications.isEmpty,
      ));
    } catch (_) {
      emit(PublicationFailure());
    }
  }
}
