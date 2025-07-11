import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mobile/core/globals/publications/publications.dart';

part 'publication_event.dart';
part 'publication_state.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class PublicationBloc extends Bloc<PublicationEvent, PublicationState> {
  final PublicationRepository publicationRepository;
  static const int _limit = 10;
  int _currentPage = 1;
  String time = "";

  PublicationBloc({required this.publicationRepository})
    : super(PublicationInitial()) {
    on<LoadPublications>(_onLoadPublications);
    // Apply a 300ms debounce to LoadMorePublications:
    on<LoadMorePublications>(
      _onLoadMorePublications,
      transformer: debounce<LoadMorePublications>(
        const Duration(milliseconds: 300),
      ),
    );
    on<RefreshPublications>(
      _onRefreshPublications,
      transformer: debounce<RefreshPublications>(
        const Duration(milliseconds: 300),
      ),
    );
    on<HidePublication>(_onHidePublication);
  }

  Future<void> _onLoadPublications(
    LoadPublications event,
    Emitter<PublicationState> emit,
  ) async {
    emit(PublicationLoading());
    _currentPage = 1;
    try {
      PublicationResponse response;
      if (event.isFeed) {
        response = await publicationRepository.fetchPublications(
          page: _currentPage,
          limit: _limit,
          time: DateTime.now().toIso8601String(),
          isOtherUser: event.isOtherUser,
        );
      } else {
        response = await publicationRepository.fetchPublications(
          page: _currentPage,
          limit: _limit,
        );
      }
      emit(
        PublicationSuccess(
          publications: response.publications,
          totalPosts: response.totalPosts,
          totalPages: response.totalPages,
          currentPage: response.currentPage,
          hasReachedMax:
              response.publications.length <
              10, // Adjust this logic using number of pages
        ),
      );
    } catch (_) {
      emit(PublicationFailure());
    }
  }

  Future<void> _onLoadMorePublications(
    LoadMorePublications event,
    Emitter<PublicationState> emit,
  ) async {
    if (state is! PublicationSuccess) return;
    final current = state as PublicationSuccess;
    if (current.hasReachedMax) return;

    final nextPage = current.currentPage + 1;
    try {
      PublicationResponse response;
      if (event.isFeed) {
        response = await publicationRepository.fetchPublications(
          page: nextPage,
          limit: _limit,
          time: current.publications.last.createdAt.toIso8601String(),
          isOtherUser: event.isOtherUser,
        );
      } else {
        response = await publicationRepository.fetchPublications(
          page: nextPage,
          limit: _limit,
        );
      }
      final all = List.of(current.publications)..addAll(response.publications);
      emit(
        PublicationSuccess(
          publications: all,
          totalPosts: response.totalPosts,
          totalPages: response.totalPages,
          currentPage: response.currentPage,
          hasReachedMax:
              response.publications.length <
              10, // todo: Adjust this logic using number of pages
        ),
      );
    } catch (_) {
      emit(PublicationFailure());
    }
  }

  Future<void> _onRefreshPublications(
    RefreshPublications event,
    Emitter<PublicationState> emit,
  ) async {
    if (state is PublicationLoading) return;
    _currentPage = 1;
    try {
      emit(PublicationLoading());
      await Future.delayed(Duration(milliseconds: 100));
      PublicationResponse response;
      if (event.isFeed) {
        response = await publicationRepository.fetchPublications(
          page: _currentPage,
          limit: _limit,
          time: DateTime.now().toIso8601String(),
          isOtherUser: event.isOtherUser,
        );
      } else {
        response = await publicationRepository.fetchPublications(
          page: _currentPage,
          limit: _limit,
        );
      }
      emit(
        PublicationSuccess(
          publications: response.publications,
          totalPosts: response.totalPosts,
          totalPages: response.totalPages,
          currentPage: response.currentPage,
        ),
      );
    } catch (_) {
      emit(PublicationFailure());
    }
  }

  void _onHidePublication(
    HidePublication event,
    Emitter<PublicationState> emit,
  ) {
    if (state is! PublicationSuccess) return;
    final current = state as PublicationSuccess;
    final updatedList =
        current.publications
            .where((pub) => pub.id != event.publicationId)
            .toList();

    emit(
      PublicationSuccess(
        publications: updatedList,
        totalPosts: current.totalPosts - 1,
        totalPages: current.totalPages,
        currentPage: current.currentPage,
      ),
    );
  }
}
