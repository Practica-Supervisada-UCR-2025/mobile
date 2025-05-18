
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/create/create.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/services/tenor_gif_service.dart';

class GifPickerBottomSheet extends StatefulWidget {
  final TenorGifService? gifService;

  const GifPickerBottomSheet({
    super.key,
    this.gifService,
  });

  @override
  State<GifPickerBottomSheet> createState() => _GifPickerBottomSheetState();
}

class _GifPickerBottomSheetState extends State<GifPickerBottomSheet> {
  final _searchController = TextEditingController();
  // final _gifService = TenorGifService();
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
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && !_isLoadingMore) {
        _loadMoreGifs();
      }
    });
  }

  Future<void> _loadTrending() async {
    try {
      _currentQuery = null;
      _currentPage = 0;
      _nextTrendingPos = null;

      final response = await _gifService.getTrendingGifs();
      if (mounted) {
        setState(() {
          _gifs = response.gifs;
          _nextTrendingPos = response.next;
          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading trending GIFs: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }



  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;

    setState(() => _loading = true);
    try {
      _currentQuery = query;
      _currentPage = 0;
      final gifs = await _gifService.searchGifs(query, pos: _currentPage);
      if (mounted) {
        setState(() {
          _gifs = gifs;
          _loading = false;
        });
      }
    } catch (e) {
      print("Error searching GIFs for '\$query': \$e");
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _loadMoreGifs() async {
    if (_isLoadingMore) return;
    _isLoadingMore = true;

    try {
      List<GifModel> more;

      if (_currentQuery != null) {
        _currentPage++;
        more = await _gifService.searchGifs(_currentQuery!, pos: _currentPage);
      } else if (_nextTrendingPos != null) {
        final response = await _gifService.getTrendingGifs(pos: _nextTrendingPos);
        more = response.gifs;
        _nextTrendingPos = response.next;
      } else {
        more = [];
      }

      if (mounted) {
        setState(() {
          _gifs.addAll(more);
        });
      }
    } catch (e) {
      print('Error loading more GIFs: $e');
    } finally {
      _isLoadingMore = false;
    }
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
              onChanged: (value) { // Agregar onChanged
                if (value.trim().isEmpty) {
                  _loadTrending();
                }
              },
            ),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator()
            else
              SizedBox(
                height: 300,
                child: GridView.builder(
                  controller: _scrollController,
                  itemCount: _gifs.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemBuilder: (_, index) {
                    final gif = _gifs[index];
                    return GestureDetector(
                      onTap: () {
                        context.read<CreatePostBloc>().add(GifSelected(gif));
                        Navigator.pop(context);
                      },
                      child: Image.network(
                        gif.tinyGifUrl,
                        fit: BoxFit.cover,
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
