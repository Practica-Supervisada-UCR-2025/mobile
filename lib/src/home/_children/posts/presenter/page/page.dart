import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class PostsPage extends StatelessWidget {
  const PostsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return 
    Container(
      color: Theme.of(context).colorScheme.surface,
      child: BlocProvider(
        create: (_) => PublicationBloc(
          publicationRepository: PublicationRepositoryAPI(endpoint: ENDPOINT_OWN_PUBLICATIONS),
        )..add(LoadPublications()),
        child: const PublicationsList(scrollKey: "allPosts"),
      ),
    );
  }
}
