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
  final List<Publication> publications;

  final int totalPosts;

  final int totalPages;

  final int currentPage;

  final bool hasReachedMax;

  const PublicationSuccess({
    required this.publications,
    required this.totalPosts,
    required this.totalPages,
    required this.currentPage,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [
    publications,
    totalPosts,
    totalPages,
    currentPage,
  ];
}
