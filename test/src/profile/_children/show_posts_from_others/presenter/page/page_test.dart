import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/core/core.dart';

class FakePublicationsList extends StatelessWidget {
  const FakePublicationsList({
    super.key,
    required this.scrollKey,
    required this.isFeed,
    required this.isOtherUser,
    required this.scrollController,
  });

  final String scrollKey;
  final bool isFeed;
  final bool isOtherUser;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class MockPublicationRepository extends Mock
    implements PublicationRepositoryAPI {}

void main() {
  late MockPublicationRepository mockRepository;
  late ScrollController scrollController;
  late GlobalKey fakePublicationsKey;

  setUp(() {
    mockRepository = MockPublicationRepository();
    scrollController = ScrollController();
    fakePublicationsKey = GlobalKey();
  });

  testWidgets('ShowPostFromOthersPage builds with PublicationsList', (
    tester,
  ) async {
    when(
      () => mockRepository.fetchPublications(
        page: any(named: 'page'),
        limit: any(named: 'limit'),
        time: any(named: 'time'),
        isOtherUser: any(named: 'isOtherUser'),
      ),
    ).thenAnswer(
      (_) async => PublicationResponse(
        publications: [],
        totalPosts: 0,
        totalPages: 1,
        currentPage: 1,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider(
            create:
                (_) =>
                    PublicationBloc(publicationRepository: mockRepository)
                      ..add(LoadPublications(isFeed: true, isOtherUser: true)),
            child: Builder(
              builder: (context) {
                return FakePublicationsList(
                  key: fakePublicationsKey,
                  scrollKey: "otherPosts",
                  isFeed: true,
                  isOtherUser: true,
                  scrollController: scrollController,
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(fakePublicationsKey), findsOneWidget);
  });
}
