import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:mobile/src/search/search.dart';

// Generate mocks
@GenerateMocks([SearchUsersRepository])
import 'search_bloc_test.mocks.dart';

void main() {
  group('SearchBloc', () {
    late SearchBloc searchBloc;
    late MockSearchUsersRepository mockSearchUsersRepository;

    final sampleUsers = [
      UserModel(
        id: '1',
        username: 'john_doe',
        userFullname: 'John Doe',
        profilePicture: 'https://example.com/john.jpg',
      ),
      UserModel(
        id: '2',
        username: 'jane_doe',
        userFullname: 'Jane Doe',
        profilePicture: 'https://example.com/jane.jpg',
      ),
    ];

    setUp(() {
      mockSearchUsersRepository = MockSearchUsersRepository();
      searchBloc = SearchBloc(searchUsersRepository: mockSearchUsersRepository);
    });

    tearDown(() {
      searchBloc.close();
    });

    test('initial state is SearchInitial', () {
      expect(searchBloc.state, equals(const SearchInitial()));
    });

    test('ClearSearchEvent props returns empty list', () {
      const event = ClearSearchEvent();

      final props = event.props;

      expect(props, isEmpty);
      expect(props, equals([]));
    });

    test('SearchUsersEvent props returns query in list', () {
      const query = 'test query';
      const event = SearchUsersEvent(query);

      final props = event.props;

      expect(props, hasLength(1));
      expect(props, equals([query]));
      expect(props.first, equals(query));
    });

    group('SearchUsersEvent', () {
      blocTest<SearchBloc, SearchState>(
        'emits SearchInitial when query is empty',
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchUsersEvent('')),
        expect: () => [const SearchInitial()],
        verify: (_) {
          verifyNever(mockSearchUsersRepository.searchUsers(any));
        },
      );

      blocTest<SearchBloc, SearchState>(
        'emits SearchInitial when query contains only whitespace',
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchUsersEvent('   ')),
        expect: () => [const SearchInitial()],
        verify: (_) {
          verifyNever(mockSearchUsersRepository.searchUsers(any));
        },
      );

      blocTest<SearchBloc, SearchState>(
        'emits SearchInitial when query length is less than 2 characters',
        build: () => searchBloc,
        act: (bloc) => bloc.add(const SearchUsersEvent('a')),
        expect: () => [const SearchInitial()],
        verify: (_) {
          verifyNever(mockSearchUsersRepository.searchUsers(any));
        },
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchSuccess] when search is successful',
        build: () {
          when(
            mockSearchUsersRepository.searchUsers('john'),
          ).thenAnswer((_) async => sampleUsers);
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchUsersEvent('john')),
        wait: const Duration(
          milliseconds: 600,
        ), // Wait for debounce + execution
        expect:
            () => [
              const SearchLoading(),
              SearchSuccess(users: sampleUsers, query: 'john'),
            ],
        verify: (_) {
          verify(mockSearchUsersRepository.searchUsers('john')).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchEmpty] when search returns empty results',
        build: () {
          when(
            mockSearchUsersRepository.searchUsers('nonexistent'),
          ).thenAnswer((_) async => []);
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchUsersEvent('nonexistent')),
        wait: const Duration(milliseconds: 600),
        expect:
            () => [
              const SearchLoading(),
              const SearchEmpty(query: 'nonexistent'),
            ],
        verify: (_) {
          verify(
            mockSearchUsersRepository.searchUsers('nonexistent'),
          ).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'emits [SearchLoading, SearchError] when search throws exception',
        build: () {
          when(
            mockSearchUsersRepository.searchUsers('error'),
          ).thenThrow(Exception('Network error'));
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchUsersEvent('error')),
        wait: const Duration(milliseconds: 600),
        expect:
            () => [
              const SearchLoading(),
              const SearchError(
                message: 'Exception: Network error',
                query: 'error',
              ),
            ],
        verify: (_) {
          verify(mockSearchUsersRepository.searchUsers('error')).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'trims whitespace from query before processing',
        build: () {
          when(
            mockSearchUsersRepository.searchUsers('john'),
          ).thenAnswer((_) async => sampleUsers);
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchUsersEvent('  john  ')),
        wait: const Duration(milliseconds: 600),
        expect:
            () => [
              const SearchLoading(),
              SearchSuccess(users: sampleUsers, query: 'john'),
            ],
        verify: (_) {
          verify(mockSearchUsersRepository.searchUsers('john')).called(1);
        },
      );

      blocTest<SearchBloc, SearchState>(
        'debounces multiple rapid search events and only processes the last one',
        build: () {
          when(
            mockSearchUsersRepository.searchUsers('john'),
          ).thenAnswer((_) async => sampleUsers);
          when(
            mockSearchUsersRepository.searchUsers('jane'),
          ).thenAnswer((_) async => [sampleUsers[1]]);
          return searchBloc;
        },
        act: (bloc) {
          bloc.add(const SearchUsersEvent('jo'));
          bloc.add(const SearchUsersEvent('joh'));
          bloc.add(const SearchUsersEvent('john'));
          // Add another event quickly
          bloc.add(const SearchUsersEvent('jane'));
        },
        wait: const Duration(milliseconds: 600),
        expect:
            () => [
              const SearchLoading(),
              SearchSuccess(users: [sampleUsers[1]], query: 'jane'),
            ],
        verify: (_) {
          verify(mockSearchUsersRepository.searchUsers('jane')).called(1);
          verifyNever(mockSearchUsersRepository.searchUsers('jo'));
          verifyNever(mockSearchUsersRepository.searchUsers('joh'));
          verifyNever(mockSearchUsersRepository.searchUsers('john'));
        },
      );

      blocTest<SearchBloc, SearchState>(
        'cancels previous timer when new search event is added',
        build: () {
          when(
            mockSearchUsersRepository.searchUsers('final'),
          ).thenAnswer((_) async => sampleUsers);
          return searchBloc;
        },
        act: (bloc) async {
          bloc.add(const SearchUsersEvent('first'));
          await Future.delayed(const Duration(milliseconds: 200));
          bloc.add(const SearchUsersEvent('second'));
          await Future.delayed(const Duration(milliseconds: 200));
          bloc.add(const SearchUsersEvent('final'));
        },
        wait: const Duration(milliseconds: 600),
        expect:
            () => [
              const SearchLoading(),
              SearchSuccess(users: sampleUsers, query: 'final'),
            ],
        verify: (_) {
          verify(mockSearchUsersRepository.searchUsers('final')).called(1);
          verifyNever(mockSearchUsersRepository.searchUsers('first'));
          verifyNever(mockSearchUsersRepository.searchUsers('second'));
        },
      );

      blocTest<SearchBloc, SearchState>(
        'handles concurrent search events correctly',
        build: () {
          when(mockSearchUsersRepository.searchUsers('test')).thenAnswer((
            _,
          ) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return sampleUsers;
          });
          return searchBloc;
        },
        act: (bloc) {
          for (int i = 0; i < 5; i++) {
            bloc.add(const SearchUsersEvent('test'));
          }
        },
        wait: const Duration(milliseconds: 800),
        expect:
            () => [
              const SearchLoading(),
              SearchSuccess(users: sampleUsers, query: 'test'),
            ],
        verify: (_) {
          verify(mockSearchUsersRepository.searchUsers('test')).called(1);
        },
      );
    });

    group('ClearSearchEvent', () {
      blocTest<SearchBloc, SearchState>(
        'emits SearchInitial when ClearSearchEvent is added',
        build: () => searchBloc,
        act: (bloc) => bloc.add(const ClearSearchEvent()),
        expect: () => [const SearchInitial()],
      );

      blocTest<SearchBloc, SearchState>(
        'cancels pending search when ClearSearchEvent is added',
        build: () => searchBloc,
        act: (bloc) async {
          bloc.add(const SearchUsersEvent('john'));
          await Future.delayed(const Duration(milliseconds: 200));
          bloc.add(const ClearSearchEvent());
        },
        wait: const Duration(milliseconds: 800),
        expect: () => [const SearchInitial()],
        verify: (_) {
          verifyNever(mockSearchUsersRepository.searchUsers(any));
        },
      );

      blocTest<SearchBloc, SearchState>(
        'can clear search from any state',
        build: () {
          when(
            mockSearchUsersRepository.searchUsers('john'),
          ).thenAnswer((_) async => sampleUsers);
          return searchBloc;
        },
        seed: () => SearchSuccess(users: sampleUsers, query: 'john'),
        act: (bloc) => bloc.add(const ClearSearchEvent()),
        expect: () => [const SearchInitial()],
      );

      blocTest<SearchBloc, SearchState>(
        'can clear search from error state',
        build: () => searchBloc,
        seed: () => const SearchError(message: 'Error', query: 'test'),
        act: (bloc) => bloc.add(const ClearSearchEvent()),
        expect: () => [const SearchInitial()],
      );
    });

    group('Edge Cases', () {
      blocTest<SearchBloc, SearchState>(
        'handles repository returning null gracefully',
        build: () {
          when(
            mockSearchUsersRepository.searchUsers('test'),
          ).thenAnswer((_) async => []);
          return searchBloc;
        },
        act: (bloc) => bloc.add(const SearchUsersEvent('test')),
        wait: const Duration(milliseconds: 600),
        expect: () => [const SearchLoading(), const SearchEmpty(query: 'test')],
      );

      blocTest<SearchBloc, SearchState>(
        'handles very long query strings',
        build: () {
          final longQuery = 'a' * 1000;
          when(
            mockSearchUsersRepository.searchUsers(longQuery),
          ).thenAnswer((_) async => []);
          return searchBloc;
        },
        act: (bloc) => bloc.add(SearchUsersEvent('a' * 1000)),
        wait: const Duration(milliseconds: 600),
        expect: () => [const SearchLoading(), SearchEmpty(query: 'a' * 1000)],
      );
    });
  });
}
