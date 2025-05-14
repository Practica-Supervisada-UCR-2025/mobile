import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/src/profile/profile.dart';

class MockPublicationRepository extends Mock implements PublicationRepository {}

void main() {
  late PublicationBloc bloc;
  late PublicationRepository repository;

  final fakePublications = List.generate(
    3,
    (i) => Publication(
      id: i + 1,
      username: 'User #$i',
      profileImageUrl: 'https://example.com/avatar$i.png',
      content: 'Post content $i',
      createdAt: DateTime.now(),
      attachment: i % 2 == 0 ? 'https://example.com/image$i.jpg' : null,
      likes: 10 + i,
      comments: 5 + i,
    ),
  );

  setUp(() {
    repository = MockPublicationRepository();
    bloc = PublicationBloc(publicationRepository: repository);
  });

  tearDown(() => bloc.close());

  group('PublicationBloc', () {
    blocTest<PublicationBloc, PublicationState>(
      'emits [Loading, Success] when LoadPublications succeeds',
      build: () {
        when(() => repository.fetchPublications(limit: any(named: 'limit')))
            .thenAnswer((_) async => fakePublications);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPublications()),
      expect: () => [
        PublicationLoading(),
        PublicationSuccess(publications: fakePublications, hasReachedMax: true),
      ],
    );

    blocTest<PublicationBloc, PublicationState>(
      'emits [Loading, Failure] when LoadPublications throws',
      build: () {
        when(() => repository.fetchPublications(limit: any(named: 'limit')))
            .thenThrow(Exception('Failed'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadPublications()),
      expect: () => [
        PublicationLoading(),
        PublicationFailure(),
      ],
    );

    blocTest<PublicationBloc, PublicationState>(
      'emits updated PublicationSuccess with more posts when LoadMorePublications succeeds',
      build: () {
        when(() => repository.fetchPublications(limit: any(named: 'limit')))
            .thenAnswer((_) async => fakePublications);
        return bloc;
      },
      seed: () => PublicationSuccess(publications: fakePublications, hasReachedMax: false),
      act: (bloc) => bloc.add(LoadMorePublications()),
      expect: () => [
        PublicationSuccess(
          publications: [...fakePublications, ...fakePublications],
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<PublicationBloc, PublicationState>(
      'does nothing when LoadMorePublications is called but hasReachedMax is true',
      build: () => bloc,
      seed: () => PublicationSuccess(publications: fakePublications, hasReachedMax: true),
      act: (bloc) => bloc.add(LoadMorePublications()),
      expect: () => [],
    );

    blocTest<PublicationBloc, PublicationState>(
      'emits Failure when LoadMorePublications throws',
      build: () {
        when(() => repository.fetchPublications(limit: any(named: 'limit')))
            .thenThrow(Exception('Fetch failed'));
        return bloc;
      },
      seed: () => PublicationSuccess(publications: fakePublications, hasReachedMax: false),
      act: (bloc) => bloc.add(LoadMorePublications()),
      expect: () => [PublicationFailure()],
    );
  });

  group('PublicationEvent Equatable coverage', () {
    test('LoadPublications props and equality', () {
      final a = LoadPublications();
      final b = LoadPublications();

      expect(a.props, []);
      expect(a, equals(b));
    });

    test('LoadMorePublications props and equality', () {
      final a = LoadMorePublications();
      final b = LoadMorePublications();

      expect(a.props, []);
      expect(a, equals(b));
    });
  });
}
