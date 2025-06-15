import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mobile/core/globals/publications/publications.dart';

class MockPublicationRepository extends Mock implements PublicationRepository {}

void main() {
  late PublicationBloc bloc;
  late MockPublicationRepository repository;

  final samplePub1 = Publication(
    id: '1',
    username: 'user1',
    profileImageUrl: 'https://img.example/1.png',
    content: 'First post',
    createdAt: DateTime.now(),
    attachment: null,
    likes: 0,
    comments: 0,
  );
  final samplePub2 = Publication(
    id: '2',
    username: 'user2',
    profileImageUrl: 'https://img.example/2.png',
    content: 'Second post',
    createdAt: DateTime.now(),
    attachment: 'https://img.example/file2.jpg',
    likes: 0,
    comments: 0,
  );

  setUp(() {
    repository = MockPublicationRepository();
    bloc = PublicationBloc(publicationRepository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('Initial loading of publications', () {
    blocTest<PublicationBloc, PublicationState>(
      'emits [Loading, Success] when fetchPublications returns a single page',
      build: () {
        when(() => repository.fetchPublications(page: 1, limit: 10)).thenAnswer(
          (_) async => PublicationResponse(
            publications: [samplePub1, samplePub2],
            totalPosts: 2,
            totalPages: 1,
            currentPage: 1,
          ),
        );
        return bloc;
      },
      act: (b) => b.add(LoadPublications()),
      expect:
          () => [
            PublicationLoading(),
            PublicationSuccess(
              publications: [samplePub1, samplePub2],
              totalPosts: 2,
              totalPages: 1,
              currentPage: 1,
            ),
          ],
      verify: (_) {
        verify(
          () => repository.fetchPublications(page: 1, limit: 10),
        ).called(1);
      },
    );

    blocTest<PublicationBloc, PublicationState>(
      'emits [Loading, Failure] when fetchPublications throws exception',
      build: () {
        when(
          () => repository.fetchPublications(page: 1, limit: 10),
        ).thenThrow(Exception('Server error'));
        return bloc;
      },
      act: (b) => b.add(LoadPublications()),
      expect: () => [PublicationLoading(), PublicationFailure()],
    );
  });

  group('Pagination of publications', () {
    blocTest<PublicationBloc, PublicationState>(
      'does not output anything when LoadMorePublications and status is not Success',
      build: () => bloc,
      act: (b) => b.add(LoadMorePublications()),
      wait: const Duration(milliseconds: 350),
      expect: () => <PublicationState>[],
    );

    blocTest<PublicationBloc, PublicationState>(
      'does not output anything when reachedMax == true',
      build: () => bloc,
      seed:
          () => PublicationSuccess(
            publications: [samplePub1],
            totalPosts: 1,
            totalPages: 1,
            currentPage: 1,
          ),
      act: (b) => b.add(LoadMorePublications()),
      wait: const Duration(milliseconds: 350),
      expect: () => <PublicationState>[],
    );

    blocTest<PublicationBloc, PublicationState>(
      'issues new list with next page and Success',
      build: () {
        when(() => repository.fetchPublications(page: 2, limit: 10)).thenAnswer(
          (_) async => PublicationResponse(
            publications: [samplePub2],
            totalPosts: 2,
            totalPages: 2,
            currentPage: 2,
          ),
        );
        return bloc;
      },
      seed:
          () => PublicationSuccess(
            publications: [samplePub1],
            totalPosts: 2,
            totalPages: 2,
            currentPage: 1,
          ),
      act: (b) => b.add(LoadMorePublications()),
      wait: const Duration(milliseconds: 350),
      expect:
          () => [
            PublicationSuccess(
              publications: [samplePub1, samplePub2],
              totalPosts: 2,
              totalPages: 2,
              currentPage: 2,
            ),
          ],
      verify: (_) {
        verify(
          () => repository.fetchPublications(page: 2, limit: 10),
        ).called(1);
      },
    );

    blocTest<PublicationBloc, PublicationState>(
      'emits Failure on LoadMorePublications when fetch throws exception',
      build: () {
        when(
          () => repository.fetchPublications(page: 2, limit: 10),
        ).thenThrow(Exception('Network error'));
        return bloc;
      },
      seed:
          () => PublicationSuccess(
            publications: [samplePub1],
            totalPosts: 2,
            totalPages: 2,
            currentPage: 1,
          ),
      act: (b) => b.add(LoadMorePublications()),
      wait: const Duration(milliseconds: 350),
      expect: () => [PublicationFailure()],
    );
  });

  group('Equatables events', () {
    test('LoadPublications equality', () {
      expect(LoadPublications(), equals(LoadPublications()));
    });
    test('LoadMorePublications equality', () {
      expect(LoadMorePublications(), equals(LoadMorePublications()));
    });
    test('RefreshPublications equality', () {
      expect(RefreshPublications(), equals(RefreshPublications()));
    });
  });

  group('PublicationSuccess hasReachedMax', () {
    test('returns true when currentPage >= totalPages', () {
      final state = PublicationSuccess(
        publications: [samplePub1],
        totalPosts: 1,
        totalPages: 1,
        currentPage: 1,
      );
      expect(state.hasReachedMax, true);
    });

    test('returns false when currentPage < totalPages', () {
      final state = PublicationSuccess(
        publications: [samplePub1],
        totalPosts: 2,
        totalPages: 2,
        currentPage: 1,
      );
      expect(state.hasReachedMax, false);
    });
  });

  group('RefreshPublications', () {
    blocTest<PublicationBloc, PublicationState>(
      'emits [Loading, Success] when refresh is triggered and repository responds',
      build: () {
        when(() => repository.fetchPublications(page: 1, limit: 10)).thenAnswer(
          (_) async => PublicationResponse(
            publications: [samplePub1],
            totalPosts: 1,
            totalPages: 1,
            currentPage: 1,
          ),
        );
        return bloc;
      },
      act: (b) => b.add(RefreshPublications()),
      expect:
          () => [
            PublicationLoading(),
            PublicationSuccess(
              publications: [samplePub1],
              totalPosts: 1,
              totalPages: 1,
              currentPage: 1,
            ),
          ],
      verify: (_) {
        verify(
          () => repository.fetchPublications(page: 1, limit: 10),
        ).called(1);
      },
    );

    blocTest<PublicationBloc, PublicationState>(
      'emits [Loading, Failure] when refresh throws exception',
      build: () {
        when(
          () => repository.fetchPublications(page: 1, limit: 10),
        ).thenThrow(Exception('Oops'));
        return bloc;
      },
      act: (b) => b.add(RefreshPublications()),
      expect: () => [PublicationLoading(), PublicationFailure()],
    );

    blocTest<PublicationBloc, PublicationState>(
      'does nothing when current state is already PublicationLoading',
      build: () => bloc,
      seed: () => PublicationLoading(),
      act: (b) => b.add(RefreshPublications()),
      expect: () => [],
    );
  });
}
