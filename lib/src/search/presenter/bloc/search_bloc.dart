import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/search/search.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchUsersRepository searchUsersRepository;
  Timer? _debounceTimer;

  // Debounce 500 milliseconds
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  SearchBloc({required this.searchUsersRepository})
    : super(const SearchInitial()) {
    on<SearchUsersEvent>(_onSearchUsers);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<SearchState> emit,
  ) async {
    // Cancel any existing debounce timer
    _debounceTimer?.cancel();

    final query = event.query.trim();

    // if the query is empty, reset to initial state
    if (query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    // if the query is less than 2 characters, emit initial state
    if (query.length < 2) {
      emit(const SearchInitial());
      return;
    }

    final completer = Completer<void>();

    // Debounce
    _debounceTimer = Timer(_debounceDuration, () async {
      try {
        if (!emit.isDone) {
          emit(const SearchLoading());
        }

        final users = await searchUsersRepository.searchUsers(query);

        if (!emit.isDone) {
          if (users.isEmpty) {
            emit(SearchEmpty(query: query));
          } else {
            emit(SearchSuccess(users: users, query: query));
          }
        }
      } catch (e) {
        if (!emit.isDone) {
          emit(SearchError(message: e.toString(), query: query));
        }
      } finally {
        completer.complete();
      }
    });

    // Wait for the debounce timer to complete
    await completer.future;
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<SearchState> emit) {
    _debounceTimer?.cancel();
    emit(const SearchInitial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
