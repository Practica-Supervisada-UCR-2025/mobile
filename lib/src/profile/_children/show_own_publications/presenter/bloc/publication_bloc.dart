import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/src/profile/profile.dart';

part 'publication_event.dart';
part 'publication_state.dart';

/// Change this line to control the number of visible posts:
/// - Use 0 to see the message “You haven't posted anything yet.”
/// - Use 1, 2, 3...9 to limit how many are displayed
/// - Use -1 to apply no limit (normal mode).
int kPublicationLimitOverride = -1;

class PublicationBloc extends Bloc<PublicationEvent, PublicationState> {
  final PublicationRepository publicationRepository;
  final int _limit = 10;
  int _skip = 0;

  PublicationBloc({required this.publicationRepository}) : super(PublicationInitial()) {
    on<LoadPublications>(_onLoadPublications);
    on<LoadMorePublications>(_onLoadMorePublications);
  }

  Future<void> _onLoadPublications(
    LoadPublications event,
    Emitter<PublicationState> emit,
  ) async {
    emit(PublicationLoading());
    _skip = 0;

    try {
      final rawPublications = await publicationRepository.fetchPublications(skip: _skip, limit: _limit);

      // VISUAL TEST FILTER
      final publications = kPublicationLimitOverride > -1
          ? rawPublications.take(kPublicationLimitOverride).toList()
          : rawPublications;

      _skip += publications.length;

      emit(PublicationSuccess(
        publications: publications,
        hasReachedMax: publications.length < _limit,
      ));
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
      final rawNewPublications = await publicationRepository.fetchPublications(skip: _skip, limit: _limit);

      // VISUAL TEST FILTER
      final newPublications = kPublicationLimitOverride > -1
          ? rawNewPublications.take(kPublicationLimitOverride).toList()
          : rawNewPublications;

      _skip += newPublications.length;

      final allPublications = List.of(currentState.publications)..addAll(newPublications);

      emit(PublicationSuccess(
        publications: allPublications,
        hasReachedMax: newPublications.length < _limit,
      ));
    } catch (_) {
      emit(PublicationFailure());
    }
  }
}
