import 'package:flutter/material.dart';
import 'package:mobile/src/shared/models/gif_model.dart';
import 'package:mobile/src/shared/services/tenor_gif_service.dart';

class GifPickerBottomSheet extends StatefulWidget {
  const GifPickerBottomSheet({super.key});

  @override
  State<GifPickerBottomSheet> createState() => _GifPickerBottomSheetState();
}

class _GifPickerBottomSheetState extends State<GifPickerBottomSheet> {
  final _searchController = TextEditingController();
  final _gifService = TenorGifService();

  List<GifModel> _gifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  Future<void> _loadTrending() async {
    final gifs = await _gifService.getTrendingGifs();
    setState(() {
      _gifs = gifs;
      _loading = false;
    });
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    final gifs = await _gifService.searchGifs(query);
    setState(() {
      _gifs = gifs;
      _loading = false;
    });
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
            ),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator()
            else
              SizedBox(
                height: 300,
                child: GridView.builder(
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
                        Navigator.pop(context, gif);
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
