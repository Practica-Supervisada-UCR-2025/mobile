import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';

part 'publication_event.dart';
part 'publication_state.dart';

class PublicationBloc extends Bloc<PublicationEvent, PublicationState> {
  final PublicationRepository publicationRepository;
  final int _limit = 10;
  int _currentPage = 1;

  PublicationBloc({required this.publicationRepository})
      : super(PublicationInitial()) {
    on<LoadPublications>(_onLoadPublications);
    on<LoadMorePublications>(_onLoadMorePublications);
  }

  Future<void> _onLoadPublications(
      LoadPublications event, Emitter<PublicationState> emit) async {
    emit(PublicationLoading());
    _currentPage = 1;

    try {
      final response = await publicationRepository.fetchPublications(
        page: _currentPage,
        limit: _limit,
      );

      emit(PublicationSuccess(
        publications: response.publications,
        totalPosts: response.totalPosts,
        totalPages: response.totalPages,
        currentPage: response.currentPage,
      ));
    } catch (_) {
      emit(PublicationFailure());
    }
  }

  Future<void> _onLoadMorePublications(
      LoadMorePublications event, Emitter<PublicationState> emit) async {
    final state = this.state;
    if (state is! PublicationSuccess) return;
    if (state.hasReachedMax) return;

    final nextPage = state.currentPage + 1;

    try {
      final response = await publicationRepository.fetchPublications(
        page: nextPage,
        limit: _limit,
      );

      final allPosts = List.of(state.publications)
        ..addAll(response.publications);

      emit(PublicationSuccess(
        publications: allPosts,
        totalPosts: response.totalPosts,
        totalPages: response.totalPages,
        currentPage: response.currentPage,
      ));
    } catch (_) {
      emit(PublicationFailure());
    }
  }
}
