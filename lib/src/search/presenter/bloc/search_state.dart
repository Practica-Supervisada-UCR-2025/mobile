import 'package:equatable/equatable.dart';
import 'package:mobile/src/search/search.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchSuccess extends SearchState {
  final List<UserModel> users;
  final String query;

  const SearchSuccess({required this.users, required this.query});

  @override
  List<Object?> get props => [users, query];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty({required this.query});

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  final String query;

  const SearchError({required this.message, required this.query});

  @override
  List<Object?> get props => [message, query];
}
