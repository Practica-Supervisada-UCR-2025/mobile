import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/core.dart';

class ShowOwnPublicationsPage extends StatelessWidget {
  final bool refresh;
  const ShowOwnPublicationsPage({super.key, this.refresh = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = PublicationBloc(
          publicationRepository: PublicationRepositoryAPI(
            endpoint: ENDPOINT_OWN_PUBLICATIONS,
          ),
        );

        if (refresh) {
          bloc.add(RefreshPublications());
        } else {
          bloc.add(LoadPublications());
        }

        return bloc;
      },
      child: const PublicationsList(scrollKey: "ownPosts"),
    );
  }
}
