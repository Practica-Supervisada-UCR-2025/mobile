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
  static const int _postLimit = 14; //Modify this to control how many posts are viewed

  @override
  void initState() {
    super.initState();
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
          final allPublications = state.publications;
          final limitedPublications = allPublications.take(_postLimit).toList();

          if (limitedPublications.isEmpty) {
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
            itemCount: limitedPublications.length + 1,
            itemBuilder: (context, index) {
              if (index < limitedPublications.length) {
                return PublicationCard(publication: limitedPublications[index]);
              } else {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: Text('No more posts to show.')),
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
