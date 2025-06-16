import 'package:flutter/material.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/services/tenor_gif_service.dart';

class GifPickerBottomSheet extends StatefulWidget {
  final TenorGifService? gifService;
  final void Function(GifModel gif) onGifSelected;

  const GifPickerBottomSheet({
    super.key,
    this.gifService,
    required this.onGifSelected,
  });

  @override
  State<GifPickerBottomSheet> createState() => _GifPickerBottomSheetState();
}

class _GifPickerBottomSheetState extends State<GifPickerBottomSheet> {
  final _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<GifModel> _gifs = [];
  bool _loading = true;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  String? _currentQuery;
  String? _nextTrendingPos;
  late final TenorGifService _gifService;

  @override
  void initState() {
    super.initState();
    _gifService = widget.gifService ?? TenorGifService();
    _loadTrending();
    _searchController.addListener(() {
      if (_searchController.text.trim().isEmpty && _currentQuery != null) {
        _loadTrending();
      }
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 100 &&
          !_isLoadingMore) {
        _loadMoreGifs();
      }
    });
  }

  Future<void> _loadTrending() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      _currentQuery = null;
      final response = await _gifService.getTrendingGifs(pos: null);
      if (mounted) {
        setState(() {
          _gifs = response.gifs;
          _nextTrendingPos = response.next;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading trending GIFs: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      _loadTrending();
      return;
    }
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      _currentQuery = query;
      _currentPage = 0;
      final gifs = await _gifService.searchGifs(query, pos: _currentPage);
      if (mounted) {
        setState(() {
          _gifs = gifs;
          _nextTrendingPos = null;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching GIFs: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMoreGifs() async {
    if (_isLoadingMore || !mounted) return;
    setState(() => _isLoadingMore = true);

    try {
      List<GifModel> moreGifs = [];
      if (_currentQuery != null) {
        _currentPage++;
        final List<GifModel> newSearchGifs = await _gifService.searchGifs(
          _currentQuery!,
          pos: _currentPage,
        );
        moreGifs.addAll(newSearchGifs);
      } else if (_nextTrendingPos != null) {
        final response = await _gifService.getTrendingGifs(
          pos: _nextTrendingPos,
        );
        moreGifs.addAll(response.gifs);
        _nextTrendingPos = response.next;
      }

      if (mounted) {
        setState(() {
          _gifs.addAll(moreGifs);
        });
      }
    } catch (e) {
      debugPrint('Error loading more GIFs: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search GIFs',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onSubmitted: _search,
              onChanged: (value) {
                if (value.trim().isEmpty) {
                  _loadTrending();
                }
              },
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_gifs.isEmpty)
              const Center(child: Text("No GIFs found."))
            else
              SizedBox(
                height: 300,
                child: GridView.builder(
                  controller: _scrollController,
                  itemCount: _gifs.length + (_isLoadingMore ? 1 : 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (_, index) {
                    if (index == _gifs.length && _isLoadingMore) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final gif = _gifs[index];
                    return GestureDetector(
                      key: Key('gif_${gif.id}'),
                      onTap: () {
                        widget.onGifSelected(gif);
                      },
                      child: Image.network(
                        gif.tinyGifUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error_outline);
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
