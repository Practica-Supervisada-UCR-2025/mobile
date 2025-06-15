import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/globals/publications/publications.dart';
import 'package:mobile/core/storage/storage.dart';

class PublicationsList extends StatefulWidget {
  final bool isFeed;
  final String scrollKey;

  const PublicationsList({super.key, required this.scrollKey, required this.isFeed});

  @override
  State<PublicationsList> createState() => _PublicationsListState();
}

class _PublicationsListState extends State<PublicationsList>
    with AutomaticKeepAliveClientMixin {
  late final ScrollController _scrollController;
  late final PublicationBloc _bloc;
  bool _showRefreshButton = false;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<PublicationBloc>();
    _scrollController = ScrollController(
      initialScrollOffset: ScrollStorage.getOffset(widget.scrollKey),
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    ScrollStorage.setOffset(widget.scrollKey, _scrollController.offset);
    if (!_scrollController.hasClients) return;

    final thresholdReached =
        _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300;

    final state = _bloc.state;
    if (thresholdReached &&
        state is PublicationSuccess &&
        !state.hasReachedMax) {
      _bloc.add(LoadMorePublications());
    }

    final shouldShow = _scrollController.offset > 600;
    if (_showRefreshButton != shouldShow) {
      setState(() {
        _showRefreshButton = shouldShow;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _showRefreshButton = false);
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      ScrollStorage.setOffset(widget.scrollKey, 0.0);
    }
    
    _bloc.add(RefreshPublications(isFeed: widget.isFeed));
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocBuilder<PublicationBloc, PublicationState>(
      builder: (context, state) {
        Widget listContent;

        if (state is PublicationLoading) {
          listContent = const Center(child: CircularProgressIndicator());
        } else if (state is PublicationFailure) {
          listContent = Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Failed to load posts'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed:
                      () => context.read<PublicationBloc>().add(
                        LoadPublications(),
                      ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is PublicationSuccess) {
          final publications = state.publications;

          if (publications.isEmpty) {
            listContent = const Center(
              child: Text(
                "You haven’t posted anything yet.",
                style: TextStyle(fontSize: 16),
              ),
            );
          } else {
            listContent = RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
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
              ),
            );
          }
        } else {
          listContent = const SizedBox.shrink();
        }

        return Stack(
          children: [
            Positioned.fill(child: listContent),
            if (_showRefreshButton)
              Positioned(
                top: 16,
                left: MediaQuery.of(context).size.width * 0.25,
                right: MediaQuery.of(context).size.width * 0.25,
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: _onRefresh,
                    icon: const Icon(Icons.arrow_upward),
                    label:
                        (state is PublicationLoading)
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Text("Recent posts"),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
