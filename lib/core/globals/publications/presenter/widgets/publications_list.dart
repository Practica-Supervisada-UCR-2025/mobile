import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/publications/publications.dart';
import 'package:mobile/core/storage/storage.dart';

class PublicationsList extends StatefulWidget {
  final bool isFeed;
  final String scrollKey;
  final bool isOtherUser;
  final ScrollController scrollController;

  const PublicationsList({
    super.key,
    required this.scrollKey,
    required this.isFeed,
    required this.isOtherUser,
    required this.scrollController,
  });

  @override
  State<PublicationsList> createState() => PublicationsListState();
}

class PublicationsListState extends State<PublicationsList>
    with AutomaticKeepAliveClientMixin {
  late final PublicationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<PublicationBloc>();
    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final scrollController = widget.scrollController;
    if (!scrollController.hasClients) return;
    final thresholdReached =
        scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 300;
    final state = _bloc.state;
    if (state is PublicationSuccess) {}
    if (thresholdReached &&
        state is PublicationSuccess &&
        !state.hasReachedMax) {
      _bloc.add(
        LoadMorePublications(
          isFeed: widget.isFeed,
          isOtherUser: widget.isOtherUser,
        ),
      );
    }
  }

  Future<void> refresh() async {
    await _onRefresh();
  }

  Future<void> _onRefresh() async {
    final scrollController = widget.scrollController;
    _bloc.add(
      RefreshPublications(
        isFeed: widget.isFeed,
        isOtherUser: widget.isOtherUser,
      ),
    );
    await _bloc.stream.firstWhere(
      (state) => state is PublicationSuccess || state is PublicationFailure,
    );
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<PublicationBloc, PublicationState>(
      builder: (context, state) {
        if (state is PublicationLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (state is PublicationFailure) {
          return SliverToBoxAdapter(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Failed to load posts'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _bloc.add(
                        LoadPublications(
                          isFeed: widget.isFeed,
                          isOtherUser: widget.isOtherUser,
                        ),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is PublicationSuccess) {
          if (state.publications.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final savedOffset = ScrollStorage.getOffset(widget.scrollKey);
              if (savedOffset > 0 && widget.scrollController.hasClients) {
                widget.scrollController.jumpTo(savedOffset);
                debugPrint(
                  '[PublicationsList] Offset restaurado en PublicationSuccess: $savedOffset',
                );
              }
            });
          }
          if (state.publications.isEmpty) {
            return const SliverToBoxAdapter(
              child: Center(
                child: Text(
                  "You haven’t posted anything yet.",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            );
          }
          return SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index >= state.publications.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child:
                        state.hasReachedMax
                            ? const Text('No more posts to show.')
                            : const CircularProgressIndicator(),
                  ),
                );
              }
              return PublicationCard(publication: state.publications[index]);
            }, childCount: state.publications.length + 1),
          );
        } else {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
