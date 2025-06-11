import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class ShowOwnPublicationsPage extends StatelessWidget {
  const ShowOwnPublicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublicationBloc(
        publicationRepository: PublicationRepositoryAPI(endpoint: ENDPOINT_OWN_PUBLICATIONS),
      )..add(LoadPublications()),
      child: const PublicationsList(scrollKey: "ownPosts"),
    );
  }
}
