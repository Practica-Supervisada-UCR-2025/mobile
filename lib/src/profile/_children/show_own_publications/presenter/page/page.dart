import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/profile/profile.dart';

class ShowOwnPublicationsPage extends StatelessWidget {
  const ShowOwnPublicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PublicationBloc(
        publicationRepository: context.read<PublicationRepository>(),
      )..add(LoadPublications()),
      child: const PublicationsList(),
    );
  }
}
