import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class ShowPostFromOthersPage extends StatelessWidget {
  final String userId;

  const ShowPostFromOthersPage({
    super.key,
    required this.userId,
    });
  

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublicationBloc(
        publicationRepository: PublicationRepositoryAPI(endpoint: '$ENDPOINT_PUBLICATIONS_FROM_OTHERS$userId' ),
      )..add(LoadPublications()),
      child: const PublicationsList(scrollKey: "otherPosts"),
    );
  }
}
