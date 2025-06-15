import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/core.dart';

class MockReportPublicationRepository extends Mock
    implements ReportPublicationRepository {}

void main() {
  late ReportPublicationBloc bloc;
  late MockReportPublicationRepository repository;

  const publicationId = '123';
  const reason = 'Inappropriate content';

  setUp(() {
    repository = MockReportPublicationRepository();
    bloc = ReportPublicationBloc(reportPublicationRepository: repository);
  });

  tearDown(() {
    bloc.close();
  });

  group('ReportPublicationBloc', () {
    test('initial state is ReportPublicationInitial', () {
      expect(bloc.state, equals(ReportPublicationInitial()));
    });

    blocTest<ReportPublicationBloc, ReportPublicationState>(
      'emits [Loading, Success] when reportPublication succeeds',
      build: () {
        when(
          () => repository.reportPublication(
            publicationId: publicationId,
            reason: reason,
          ),
        ).thenAnswer((_) async => Future.value());

        return bloc;
      },
      act:
          (b) => b.add(
            const ReportPublicationRequest(
              publicationId: publicationId,
              reason: reason,
            ),
          ),
      expect: () => [ReportPublicationLoading(), ReportPublicationSuccess()],
      verify: (_) {
        verify(
          () => repository.reportPublication(
            publicationId: publicationId,
            reason: reason,
          ),
        ).called(1);
      },
    );

    blocTest<ReportPublicationBloc, ReportPublicationState>(
      'emits [Loading, Failure] when reportPublication throws exception',
      build: () {
        when(
          () => repository.reportPublication(
            publicationId: publicationId,
            reason: reason,
          ),
        ).thenThrow(Exception('Network error'));

        return bloc;
      },
      act:
          (b) => b.add(
            const ReportPublicationRequest(
              publicationId: publicationId,
              reason: reason,
            ),
          ),
      expect:
          () => [
            ReportPublicationLoading(),
            const ReportPublicationFailure(error: 'Network error'),
          ],
    );

    blocTest<ReportPublicationBloc, ReportPublicationState>(
      'emits [Initial] when ReportPublicationReset is added',
      build: () => bloc,
      seed: () => ReportPublicationSuccess(),
      act: (b) => b.add(ReportPublicationReset()),
      expect: () => [ReportPublicationInitial()],
    );
  });

  group('Event Equality', () {
    test('ReportPublicationRequest equality', () {
      expect(
        const ReportPublicationRequest(publicationId: '1', reason: 'spam'),
        equals(
          const ReportPublicationRequest(publicationId: '1', reason: 'spam'),
        ),
      );
    });

    test('ReportPublicationReset equality', () {
      expect(ReportPublicationReset(), equals(ReportPublicationReset()));
    });
  });

  group('State Equality', () {
    test('ReportPublicationFailure equality', () {
      expect(
        const ReportPublicationFailure(error: 'Error'),
        equals(const ReportPublicationFailure(error: 'Error')),
      );
    });

    test('ReportPublicationInitial equality', () {
      expect(ReportPublicationInitial(), equals(ReportPublicationInitial()));
    });

    test('ReportPublicationSuccess equality', () {
      expect(ReportPublicationSuccess(), equals(ReportPublicationSuccess()));
    });

    test('ReportPublicationLoading equality', () {
      expect(ReportPublicationLoading(), equals(ReportPublicationLoading()));
    });
  });
}
