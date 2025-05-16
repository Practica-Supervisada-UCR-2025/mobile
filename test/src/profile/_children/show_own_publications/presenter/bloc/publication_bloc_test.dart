// test/publication_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
// Import the bloc, events, states, model and override variable
import 'package:mobile/src/profile/profile.dart';
import 'package:mobile/src/profile/_children/show_own_publications/presenter/bloc/publication_bloc.dart' as bloc_file;

class MockPublicationRepository extends Mock implements PublicationRepository {}

void main() {
  late PublicationBloc bloc;
  late PublicationRepository repository;

  // A small fake list of 3 items (< limit = 10)
  final fakePublications = List.generate(
    3,
    (i) => Publication(
      id: i + 1,
      username: 'User #$i',
      profileImageUrl: 'https://example.com/avatar$i.png',
      content: 'Post content $i',
      createdAt: DateTime.now(),
      attachment: i.isEven ? 'https://example.com/image$i.jpg' : null,
      likes: 10 + i,
      comments: 5 + i,
    ),
  );

  setUp(() {
    repository = MockPublicationRepository();
    bloc = PublicationBloc(publicationRepository: repository);
    // reset the override to -1 (no limit)
    bloc_file.kPublicationLimitOverride = -1;
  });

  tearDown(() => bloc.close());

  group('PublicationBloc estándar (override = -1)', () {
    blocTest<PublicationBloc, PublicationState>(
      'LoadPublications → fewer than limit emits Loading then Success(hasReachedMax: true)',
      build: () {
        when(() => repository.fetchPublications(skip: any(named: 'skip'), limit: any(named: 'limit')))
          .thenAnswer((_) async => fakePublications);
        return bloc;
      },
      act: (b) => b.add(LoadPublications()),
      expect: () => [
        PublicationLoading(),
        isA<PublicationSuccess>()
          .having((s) => s.publications, 'publications', fakePublications)
          .having((s) => s.hasReachedMax, 'hasReachedMax', isTrue),
      ],
      verify: (_) {
        verify(() => repository.fetchPublications(skip: 0, limit: 10)).called(1);
      },
    );

    blocTest<PublicationBloc, PublicationState>(
      'LoadPublications → exactly limit emits Loading then Success(hasReachedMax: false)',
      build: () {
        final ten = List.generate(
          10,
          (i) => Publication(
            id: i,
            username: 'U$i',
            profileImageUrl: 'https://example.com/a$i.png',
            content: 'P$i',
            createdAt: DateTime.now(),
            attachment: null,
            likes: i,
            comments: i,
          ),
        );
        when(() => repository.fetchPublications(skip: any(named: 'skip'), limit: any(named: 'limit')))
          .thenAnswer((_) async => ten);
        return bloc;
      },
      act: (b) => b.add(LoadPublications()),
      expect: () => [
        PublicationLoading(),
        isA<PublicationSuccess>()
          .having((s) => s.publications.length, 'length', 10)
          .having((s) => s.hasReachedMax, 'hasReachedMax', isFalse),
      ],
      verify: (_) {
        verify(() => repository.fetchPublications(skip: 0, limit: 10)).called(1);
      },
    );

    blocTest<PublicationBloc, PublicationState>(
      'LoadPublications → exception emits Loading then Failure',
      build: () {
        when(() => repository.fetchPublications(skip: any(named: 'skip'), limit: any(named: 'limit')))
          .thenThrow(Exception('oops'));
        return bloc;
      },
      act: (b) => b.add(LoadPublications()),
      expect: () => [PublicationLoading(), PublicationFailure()],
    );

    blocTest<PublicationBloc, PublicationState>(
      'LoadMorePublications when not in Success state does nothing',
      build: () => bloc,
      act: (b) => b.add(LoadMorePublications()),
      expect: () => [],
    );

    blocTest<PublicationBloc, PublicationState>(
      'LoadMorePublications → adds more and then hasReachedMax=true when fewer returned than limit',
      seed: () => PublicationSuccess(publications: fakePublications, hasReachedMax: false),
      build: () {
        when(() => repository.fetchPublications(skip: any(named: 'skip'), limit: any(named: 'limit')))
          .thenAnswer((_) async => fakePublications);
        return bloc;
      },
      act: (b) => b.add(LoadMorePublications()),
      expect: () => [
        isA<PublicationSuccess>()
          .having((s) => s.publications.length, 'total', fakePublications.length * 2)
          .having((s) => s.hasReachedMax, 'hasReachedMax', isTrue),
      ],
    );

    blocTest<PublicationBloc, PublicationState>(
      'LoadMorePublications → adds more and hasReachedMax=false when exactly limit returned',
      seed: () => PublicationSuccess(publications: const [], hasReachedMax: false),
      build: () {
        final tenNew = List.generate(
          10,
          (i) => Publication(
            id: 100 + i,
            username: 'New$i',
            profileImageUrl: 'https://example.com/n$i.png',
            content: 'C$i',
            createdAt: DateTime.now(),
            attachment: null,
            likes: 0,
            comments: 0,
          ),
        );
        when(() => repository.fetchPublications(skip: any(named: 'skip'), limit: any(named: 'limit')))
          .thenAnswer((_) async => tenNew);
        return bloc;
      },
      act: (b) => b.add(LoadMorePublications()),
      expect: () => [
        isA<PublicationSuccess>()
          .having((s) => s.publications.length, 'new total', 10)
          .having((s) => s.hasReachedMax, 'hasReachedMax', isFalse),
      ],
      verify: (_) {
        verify(() => repository.fetchPublications(skip: 0, limit: 10)).called(1);
      },
    );

    blocTest<PublicationBloc, PublicationState>(
      'LoadMorePublications when hasReachedMax=true does nothing',
      seed: () => PublicationSuccess(publications: fakePublications, hasReachedMax: true),
      build: () => bloc,
      act: (b) => b.add(LoadMorePublications()),
      expect: () => [],
    );

    blocTest<PublicationBloc, PublicationState>(
      'LoadMorePublications → exception emits Failure',
      seed: () => PublicationSuccess(publications: fakePublications, hasReachedMax: false),
      build: () {
        when(() => repository.fetchPublications(skip: any(named: 'skip'), limit: any(named: 'limit')))
          .thenThrow(Exception('bad'));
        return bloc;
      },
      act: (b) => b.add(LoadMorePublications()),
      expect: () => [PublicationFailure()],
    );
  });

  group('PublicationBloc con override > -1', () {
    setUp(() {
      // Force the take(...) branch
      bloc_file.kPublicationLimitOverride = 1;
    });

    blocTest<PublicationBloc, PublicationState>(
      'LoadPublications → takes only 1 then hasReachedMax=true',
      build: () {
        when(() => repository.fetchPublications(skip: any(named: 'skip'), limit: any(named: 'limit')))
          .thenAnswer((_) async => fakePublications);
        return bloc;
      },
      act: (b) => b.add(LoadPublications()),
      expect: () => [
        PublicationLoading(),
        isA<PublicationSuccess>()
          .having((s) => s.publications.length, 'length', 1)
          .having((s) => s.hasReachedMax, 'hasReachedMax', isTrue),
      ],
    );

    blocTest<PublicationBloc, PublicationState>(
      'LoadMorePublications → takes only 1 more then hasReachedMax=true',
      seed: () => PublicationSuccess(publications: fakePublications, hasReachedMax: false),
      build: () {
        when(() => repository.fetchPublications(skip: any(named: 'skip'), limit: any(named: 'limit')))
          .thenAnswer((_) async => fakePublications);
        return bloc;
      },
      act: (b) => b.add(LoadMorePublications()),
      expect: () => [
        isA<PublicationSuccess>()
          .having((s) => s.publications.length, 'length', fakePublications.length + 1)
          .having((s) => s.hasReachedMax, 'hasReachedMax', isTrue),
      ],
    );
  });

  group('PublicationEvent Equatable', () {
    test('LoadPublications equality', () {
      expect(LoadPublications(), equals(LoadPublications()));
    });
    test('LoadMorePublications equality', () {
      expect(LoadMorePublications(), equals(LoadMorePublications()));
    });
  });
}
