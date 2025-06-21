import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class ShowPostFromOthersPage extends StatelessWidget {
  final String userId;
  final bool? refresh;
  final bool isFeed;

  const ShowPostFromOthersPage({
    super.key,
    required this.userId,
    this.refresh,
    this.isFeed = true,
    });
  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublicationBloc(
        publicationRepository: PublicationRepositoryAPI(endpoint: '$ENDPOINT_PUBLICATIONS_FROM_OTHERS$userId' ),
      )..add(LoadPublications(isFeed: true, isOtherUser: true)),
      child: const PublicationsList(scrollKey: "otherPosts", isFeed: true, isOtherUser: true),
    );
  }
}
