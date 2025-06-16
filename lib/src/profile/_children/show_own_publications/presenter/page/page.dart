import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/core/core.dart';

class ShowOwnPublicationsPage extends StatefulWidget {
  const ShowOwnPublicationsPage({super.key});

  @override
  State<ShowOwnPublicationsPage> createState() =>
      _ShowOwnPublicationsPageState();
}

class _ShowOwnPublicationsPageState extends State<ShowOwnPublicationsPage> {
  int? _lastRefreshTimestamp;
  late PublicationBloc _publicationBloc;

  @override
  void initState() {
    super.initState();
    _publicationBloc = PublicationBloc(
      publicationRepository: PublicationRepositoryAPI(
        endpoint: ENDPOINT_OWN_PUBLICATIONS,
      ),
    )..add(LoadPublications());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final extra = GoRouterState.of(context).extra;
    final currentRefresh = extra is Map ? extra['refresh'] as int? : null;

    if (_lastRefreshTimestamp != currentRefresh && currentRefresh != null) {
      _lastRefreshTimestamp = currentRefresh;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _publicationBloc.add(RefreshPublications());
        }
      });
    }
  }

  @override
  void dispose() {
    _publicationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _publicationBloc,
      child: const PublicationsList(scrollKey: "ownPosts"),
    );
  }
}
