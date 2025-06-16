import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/core.dart';

class MockDeletePublicationRepository extends Mock
    implements DeletePublicationRepository {}

void main() {
  late DeletePublicationRepository mockRepository;
  late DeletePublicationBloc bloc;

  setUp(() {
    mockRepository = MockDeletePublicationRepository();
    bloc = DeletePublicationBloc(deletePublicationRepository: mockRepository);
  });

  tearDown(() => bloc.close());

  group('DeletePublicationBloc', () {
    const publicationId = '123';

    blocTest<DeletePublicationBloc, DeletePublicationState>(
      'emits [Loading, Success] when delete succeeds',
      build: () {
        when(
          () => mockRepository.deletePublication(
            publicationId: any(named: 'publicationId'),
          ),
        ).thenAnswer((_) async => Future.value());
        return bloc;
      },
      act:
          (bloc) => bloc.add(
            const DeletePublicationRequest(publicationId: publicationId),
          ),
      expect: () => [DeletePublicationLoading(), DeletePublicationSuccess()],
    );

    blocTest<DeletePublicationBloc, DeletePublicationState>(
      'emits [Loading, Failure] when delete throws exception',
      build: () {
        when(
          () => mockRepository.deletePublication(
            publicationId: any(named: 'publicationId'),
          ),
        ).thenThrow(Exception('Delete failed'));
        return bloc;
      },
      act:
          (bloc) => bloc.add(
            const DeletePublicationRequest(publicationId: publicationId),
          ),
      expect:
          () => [
            DeletePublicationLoading(),
            const DeletePublicationFailure(error: 'Delete failed'),
          ],
    );

    blocTest<DeletePublicationBloc, DeletePublicationState>(
      'emits [Initial] when DeletePublicationReset is added',
      build: () => bloc,
      act: (bloc) => bloc.add(DeletePublicationReset()),
      expect: () => [DeletePublicationInitial()],
    );
  });
}
