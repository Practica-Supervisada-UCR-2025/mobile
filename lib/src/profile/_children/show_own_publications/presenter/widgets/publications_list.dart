import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/profile/profile.dart';

class PublicationsList extends StatefulWidget {
  const PublicationsList({super.key});

  @override
  State<PublicationsList> createState() => _PublicationsListState();
}

class _PublicationsListState extends State<PublicationsList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final thresholdReached = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300;

    final state = context.read<PublicationBloc>().state;
    if (thresholdReached && state is PublicationSuccess && !state.hasReachedMax) {
      context.read<PublicationBloc>().add(LoadMorePublications());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PublicationBloc, PublicationState>(
      builder: (context, state) {
        if (state is PublicationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PublicationFailure) {
          return Center(
            child: Column(
              children: [
                const Text('Failed to load posts'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => context.read<PublicationBloc>().add(LoadPublications()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is PublicationSuccess) {
          final publications = state.publications;

          if (publications.isEmpty) {
            return const Center(
              child: Text(
                "You haven’t posted anything yet.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: publications.length + 1,
            itemBuilder: (context, index) {
              if (index < publications.length) {
                return PublicationCard(publication: publications[index]);
              } else {
                return state.hasReachedMax
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: Text('No more posts to show.')),
                      )
                    : const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
              }
            },
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
