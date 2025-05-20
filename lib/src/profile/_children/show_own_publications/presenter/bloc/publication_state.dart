part of 'publication_bloc.dart';

abstract class PublicationState extends Equatable {
  const PublicationState();
  @override
  List<Object?> get props => [];
}

class PublicationInitial extends PublicationState {}

class PublicationLoading extends PublicationState {}

class PublicationFailure extends PublicationState {}

class PublicationSuccess extends PublicationState {
  /// All posts fetched so far.
  final List<Publication> publications;

  /// Total number of posts on server.
  final int totalPosts;

  /// Total number of pages available.
  final int totalPages;

  /// The current page number returned by the last API call.
  final int currentPage;

  const PublicationSuccess({
    required this.publications,
    required this.totalPosts,
    required this.totalPages,
    required this.currentPage,
  });

  /// Whether we have fetched all pages.
  bool get hasReachedMax => currentPage >= totalPages;

  @override
  List<Object?> get props =>
      [publications, totalPosts, totalPages, currentPage];
}

