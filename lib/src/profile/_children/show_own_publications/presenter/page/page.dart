import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class ShowOwnPublicationsPage extends StatelessWidget {
  final bool isFeed;
  final GlobalKey<PublicationsListState> publicationsKey;
  final ScrollController scrollController;
  final scrollKey = "ownPosts";

  const ShowOwnPublicationsPage({
    super.key,
    this.isFeed = false,
    required this.publicationsKey,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.hasClients) {
        final currentOffset = scrollController.offset;
        ScrollStorage.setOffset(scrollKey, currentOffset);
      }
    });

    return BlocProvider(
      create:
          (_) => PublicationBloc(
            publicationRepository: PublicationRepositoryAPI(
              endpoint: ENDPOINT_OWN_PUBLICATIONS,
            ),
          )..add(LoadPublications(isFeed: false, isOtherUser: false)),
      child: PublicationsList(
        key: publicationsKey,
        scrollKey: scrollKey,
        isFeed: false,
        isOtherUser: false,
        scrollController: scrollController,
      ),
    );
  }
}
