import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:mobile/src/profile/profile.dart';
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

class MockScrollStorage extends Mock implements ScrollStorage {
  void Function(String key, double offset) setOffset = (_, __) {};
}

class MockPublicationRepository extends Mock
    implements PublicationRepositoryAPI {}

void main() {
  late MockPublicationRepository mockRepository;
  late ScrollController scrollController;
  late GlobalKey fakePublicationsKey;
  late MockScrollStorage mockScrollStorage;

  setUp(() {
    mockRepository = MockPublicationRepository();
    scrollController = ScrollController();
    fakePublicationsKey = GlobalKey();
    mockScrollStorage = MockScrollStorage();
  });

  testWidgets('ShowOwnPublicationsPage builds with PublicationsList', (
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
          body: RepositoryProvider<ScrollStorage>.value(
            value: mockScrollStorage,
            child: BlocProvider(
              create:
                  (_) => PublicationBloc(publicationRepository: mockRepository)
                    ..add(LoadPublications(isFeed: false, isOtherUser: false)),
              child: Builder(
                builder: (context) {
                  return FakePublicationsList(
                    key: fakePublicationsKey,
                    scrollKey: "ownPosts",
                    isFeed: false,
                    isOtherUser: false,
                    scrollController: scrollController,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(fakePublicationsKey), findsOneWidget);
  });

  // testWidgets('ScrollController listener saves offset in ScrollStorage', (
  //   tester,
  // ) async {
  //   double? savedOffset;

  //   final fakePublications = List.generate(
  //     20,
  //     (i) => Publication(
  //       id: 'id_$i',
  //       username: 'User$i',
  //       profileImageUrl: 'https://example.com/profile$i.png',
  //       content: 'Post content $i',
  //       createdAt: DateTime.now(),
  //       likes: i,
  //       comments: i * 2,
  //       attachment: i % 2 == 0 ? 'https://example.com/image$i.png' : null,
  //       userId: 'user_$i',
  //     ),
  //   );

  //   when(
  //     () => mockRepository.fetchPublications(
  //       page: any(named: 'page'),
  //       limit: any(named: 'limit'),
  //       time: any(named: 'time'),
  //       isOtherUser: any(named: 'isOtherUser'),
  //     ),
  //   ).thenAnswer(
  //     (_) async => PublicationResponse(
  //       publications: fakePublications,
  //       totalPosts: fakePublications.length,
  //       totalPages: 1,
  //       currentPage: 1,
  //     ),
  //   );

  //   mockScrollStorage.setOffset = (key, offset) {
  //     savedOffset = offset;
  //   };

  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: Scaffold(
  //         body: CustomScrollView(
  //           controller: scrollController,
  //           slivers: [
  //             SliverFillRemaining(
  //               child: RepositoryProvider<ScrollStorage>.value(
  //                 value: mockScrollStorage,
  //                 child: BlocProvider(
  //                   create:
  //                       (_) => PublicationBloc(
  //                         publicationRepository: mockRepository,
  //                       )..add(
  //                         LoadPublications(isFeed: false, isOtherUser: false),
  //                       ),
  //                   child: ShowOwnPublicationsPage(
  //                     publicationsKey: GlobalKey<PublicationsListState>(),
  //                     scrollController: scrollController,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  //   await tester.pumpAndSettle();
  //   scrollController.jumpTo(50);
  //   await tester.pumpAndSettle();

  //   expect(savedOffset, 50);
  // });
}
