import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/profile/_children/show_own_publications/show_own_publications.dart';

class ShowOwnPublicationsPage extends StatelessWidget {
  const ShowOwnPublicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PublicationBloc(
        publicationRepository: PublicationRepositoryAPI(),
      )..add(LoadPublications()),
      child: const PublicationsList(),
    );
  }
}
