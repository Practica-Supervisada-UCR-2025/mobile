import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchUsersEvent extends SearchEvent {
  final String query;

  const SearchUsersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends SearchEvent {
  const ClearSearchEvent();
}
