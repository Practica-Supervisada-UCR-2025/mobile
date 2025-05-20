// test/publication_bloc_test.dart

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Import your BLoC, events, states, repository interface and models
import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';

/// A mock PublicationRepository so we can control its output in tests.
class MockPublicationRepository extends Mock implements PublicationRepository {}

void main() {
  late PublicationBloc bloc;
  late PublicationRepository repository;

  // Two sample publications to use in the tests
  final samplePub1 = Publication(
    id: 1,
    username: 'user1',
    profileImageUrl: 'https://img.example/1.png',
    content: 'First post',
    createdAt: DateTime.now(),
    attachment: null,
    likes: 0,
    comments: 0,
  );
  final samplePub2 = Publication(
    id: 2,
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

  group('Carga inicial de publicaciones', () {
    blocTest<PublicationBloc, PublicationState>(
      'emite [Loading, Success] cuando fetchPublications devuelve una sola página',
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
      expect: () => [
        PublicationLoading(),
        PublicationSuccess(
          publications: [samplePub1, samplePub2],
          totalPosts: 2,
          totalPages: 1,
          currentPage: 1,
        ),
      ],
      verify: (_) {
        verify(() => repository.fetchPublications(page: 1, limit: 10)).called(1);
      },
    );

    blocTest<PublicationBloc, PublicationState>(
      'emite [Loading, Failure] cuando fetchPublications lanza excepción',
      build: () {
        when(() => repository.fetchPublications(page: 1, limit: 10))
            .thenThrow(Exception('Server error'));
        return bloc;
      },
      act: (b) => b.add(LoadPublications()),
      expect: () => [
        PublicationLoading(),
        PublicationFailure(),
      ],
    );
  });

  group('Paginación de publicaciones', () {
    blocTest<PublicationBloc, PublicationState>(
      'no emite nada cuando LoadMorePublications y estado no es Success',
      build: () => bloc,
      act: (b) => b.add(LoadMorePublications()),
      expect: () => <PublicationState>[],
    );

    blocTest<PublicationBloc, PublicationState>(
      'no emite nada cuando ya reachedMax == true',
      build: () => bloc,
      seed: () => PublicationSuccess(
        publications: [samplePub1],
        totalPosts: 1,
        totalPages: 1,
        currentPage: 1,
      ),
      act: (b) => b.add(LoadMorePublications()),
      expect: () => <PublicationState>[],
    );

    blocTest<PublicationBloc, PublicationState>(
      'emite nueva lista con página siguiente y Success',
      build: () {
        when(() => repository.fetchPublications(page: 2, limit: 10))
            .thenAnswer(
          (_) async => PublicationResponse(
            publications: [samplePub2],
            totalPosts: 2,
            totalPages: 2,
            currentPage: 2,
          ),
        );
        return bloc;
      },
      seed: () => PublicationSuccess(
        publications: [samplePub1],
        totalPosts: 2,
        totalPages: 2,
        currentPage: 1,
      ),
      act: (b) => b.add(LoadMorePublications()),
      expect: () => [
        PublicationSuccess(
          publications: [samplePub1, samplePub2],
          totalPosts: 2,
          totalPages: 2,
          currentPage: 2,
        ),
      ],
      verify: (_) {
        verify(() => repository.fetchPublications(page: 2, limit: 10)).called(1);
      },
    );

    blocTest<PublicationBloc, PublicationState>(
      'emite Failure en LoadMorePublications cuando fetch lanza excepción',
      build: () {
        when(() => repository.fetchPublications(page: 2, limit: 10))
            .thenThrow(Exception('Network error'));
        return bloc;
      },
      seed: () => PublicationSuccess(
        publications: [samplePub1],
        totalPosts: 2,
        totalPages: 2,
        currentPage: 1,
      ),
      act: (b) => b.add(LoadMorePublications()),
      expect: () => [
        PublicationFailure(),
      ],
    );
  });

  group('Eventos equatables', () {
    test('LoadPublications equality', () {
      expect(LoadPublications(), equals(LoadPublications()));
    });
    test('LoadMorePublications equality', () {
      expect(LoadMorePublications(), equals(LoadMorePublications()));
    });
  });
}
